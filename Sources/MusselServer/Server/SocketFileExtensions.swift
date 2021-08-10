// Copyright © 2021 Compass. All rights reserved.

import Foundation

#if os(iOS) || os(tvOS) || os(Linux)
    // swiftlint:disable type_name function_parameter_count
    struct sf_hdtr { }

    private func sendfileImpl(_ source: UnsafeMutablePointer<FILE>, _ target: Int32, _: off_t, _: UnsafeMutablePointer<off_t>, _: UnsafeMutablePointer<sf_hdtr>, _: Int32) -> Int32 {
        var buffer = [UInt8](repeating: 0, count: 1024)
        while true {
            let readResult = fread(&buffer, 1, buffer.count, source)
            guard readResult > 0 else {
                return Int32(readResult)
            }
            var writeCounter = 0
            while writeCounter < readResult {
                #if os(Linux)
                    let writeResult = send(target, &buffer + writeCounter, readResult - writeCounter, Int32(MSG_NOSIGNAL))
                #else
                    let writeResult = write(target, &buffer + writeCounter, readResult - writeCounter)
                #endif
                guard writeResult > 0 else {
                    return Int32(writeResult)
                }
                writeCounter += writeResult
            }
        }
    }
#endif

public extension Socket {
    func writeFile(_ file: String.File) throws {
        var offset: off_t = 0
        var sf = sf_hdtr()

        #if os(iOS) || os(tvOS) || os(Linux)
            let result = sendfileImpl(file.pointer, socketFileDescriptor, 0, &offset, &sf, 0)
        #else
            let result = sendfile(fileno(file.pointer), socketFileDescriptor, 0, &offset, &sf, 0)
        #endif

        if result == -1 {
            throw SocketError.writeFailed("sendfile: " + Errno.description())
        }
    }
}
