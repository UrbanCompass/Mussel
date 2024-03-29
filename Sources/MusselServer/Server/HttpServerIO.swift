// Copyright © 2021 Compass. All rights reserved.

import Dispatch
import Foundation

public protocol HttpServerIODelegate: AnyObject {
    func socketConnectionReceived(_ socket: Socket)
}

public class HttpServerIO {
    public weak var delegate: HttpServerIODelegate?

    private var socket = Socket(socketFileDescriptor: -1)
    private var sockets = Set<Socket>()

    public enum HttpServerIOState: Int32 {
        case starting
        case running
        case stopping
        case stopped
    }

    private var stateValue: Int32 = HttpServerIOState.stopped.rawValue

    public private(set) var state: HttpServerIOState {
        get {
            HttpServerIOState(rawValue: stateValue)!
        }
        set(state) {
            #if !os(Linux)
                OSAtomicCompareAndSwapInt(self.state.rawValue, state.rawValue, &stateValue)
            #else
                stateValue = state.rawValue
            #endif
        }
    }

    public var operating: Bool { state == .running }

    /// String representation of the IPv4 address to receive requests from.
    /// It's only used when the server is started with `forceIPv4` option set to true.
    /// Otherwise, `listenAddressIPv6` will be used.
    public var listenAddressIPv4: String?

    /// String representation of the IPv6 address to receive requests from.
    /// It's only used when the server is started with `forceIPv4` option set to false.
    /// Otherwise, `listenAddressIPv4` will be used.
    public var listenAddressIPv6: String?

    private let queue = DispatchQueue(label: "swifter.httpserverio.clientsockets")

    public func port() throws -> Int {
        Int(try socket.port())
    }

    public func isIPv4() throws -> Bool {
        try socket.isIPv4()
    }

    deinit {
        stop()
    }

    @available(macOS 10.10, *)
    public func start(_ port: in_port_t = 8080, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = DispatchQoS.QoSClass.background) throws {
        guard !operating else { return }
        stop()
        state = .starting
        let address = forceIPv4 ? listenAddressIPv4 : listenAddressIPv6
        socket = try Socket.tcpSocketForListen(port, forceIPv4, SOMAXCONN, address)
        state = .running
        DispatchQueue.global(qos: priority).async { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.operating else { return }
            while let socket = try? strongSelf.socket.acceptClientSocket() {
                DispatchQueue.global(qos: priority).async { [weak self] in
                    guard let strongSelf = self else { return }
                    guard strongSelf.operating else { return }
                    strongSelf.queue.async {
                        strongSelf.sockets.insert(socket)
                    }

                    strongSelf.handleConnection(socket)

                    strongSelf.queue.async {
                        strongSelf.sockets.remove(socket)
                    }
                }
            }
            strongSelf.stop()
        }
    }

    public func stop() {
        guard operating else { return }
        state = .stopping
        // Shutdown connected peers because they can live in 'keep-alive' or 'websocket' loops.
        for socket in sockets {
            socket.close()
        }
        queue.sync {
            self.sockets.removeAll(keepingCapacity: true)
        }
        socket.close()
        state = .stopped
    }

    public func dispatch(_ request: HttpRequest) -> ([String: String], (HttpRequest) -> HttpResponse) {
        return ([:], { _ in HttpResponse.notFound })
    }

    private func handleConnection(_ socket: Socket) {
        let parser = HttpParser()
        while operating, let request = try? parser.readHttpRequest(socket) {
            let request = request
            request.address = try? socket.peername()
            let (params, handler) = dispatch(request)
            request.params = params
            let response = handler(request)
            var keepConnection = parser.supportsKeepAlive(request.headers)
            do {
                if operating {
                    keepConnection = try respond(socket, response: response, keepAlive: keepConnection)
                }
            } catch {
                print("Failed to send response: \(error)")
                break
            }
            if let session = response.socketSession() {
                delegate?.socketConnectionReceived(socket)
                session(socket)
                break
            }
            if !keepConnection { break }
        }
        socket.close()
    }

    private struct InnerWriteContext: HttpResponseBodyWriter {
        let socket: Socket

        func write(_ file: String.File) throws {
            try socket.writeFile(file)
        }

        func write(_ data: [UInt8]) throws {
            try write(ArraySlice(data))
        }

        func write(_ data: ArraySlice<UInt8>) throws {
            try socket.writeUInt8(data)
        }

        func write(_ data: NSData) throws {
            try socket.writeData(data)
        }

        func write(_ data: Data) throws {
            try socket.writeData(data)
        }
    }

    private func respond(_ socket: Socket, response: HttpResponse, keepAlive: Bool) throws -> Bool {
        guard operating else { return false }

        // Some web-socket clients (like Jetfire) expects to have header section in a single packet.
        // We can't promise that but make sure we invoke "write" only once for response header section.

        var responseHeader = String()

        responseHeader.append("HTTP/1.1 \(response.statusCode) \(response.reasonPhrase)\r\n")

        let content = response.content()

        if content.length >= 0 {
            responseHeader.append("Content-Length: \(content.length)\r\n")
        }

        if keepAlive && content.length != -1 {
            responseHeader.append("Connection: keep-alive\r\n")
        }

        for (name, value) in response.headers() {
            responseHeader.append("\(name): \(value)\r\n")
        }

        responseHeader.append("\r\n")

        try socket.writeUTF8(responseHeader)

        if let writeClosure = content.write {
            let context = InnerWriteContext(socket: socket)
            try writeClosure(context)
        }

        return keepAlive && content.length != -1
    }
}
