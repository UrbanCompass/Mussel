//  Copyright © 2020 Compass. All rights reserved.

import Foundation

public class HttpServer: HttpServerIO {

    public static let VERSION = "1.4.7"

    private let router = HttpRouter()

    public override init() {
        self.DELETE = MethodRoute(method: "DELETE", router: router)
        self.PATCH  = MethodRoute(method: "PATCH", router: router)
        self.HEAD   = MethodRoute(method: "HEAD", router: router)
        self.POST   = MethodRoute(method: "POST", router: router)
        self.GET    = MethodRoute(method: "GET", router: router)
        self.PUT    = MethodRoute(method: "PUT", router: router)

        self.delete = MethodRoute(method: "DELETE", router: router)
        self.patch  = MethodRoute(method: "PATCH", router: router)
        self.head   = MethodRoute(method: "HEAD", router: router)
        self.post   = MethodRoute(method: "POST", router: router)
        self.get    = MethodRoute(method: "GET", router: router)
        self.put    = MethodRoute(method: "PUT", router: router)
    }

    public var DELETE, PATCH, HEAD, POST, GET, PUT: MethodRoute
    public var delete, patch, head, post, get, put: MethodRoute

    public subscript(path: String) -> ((HttpRequest) -> HttpResponse)? {
        set {
            router.register(nil, path: path, handler: newValue)
        }
        get { return nil }
    }

    public var routes: [String] {
        return router.routes()
    }

    public var notFoundHandler: ((HttpRequest) -> HttpResponse)?

    public var middleware = [(HttpRequest) -> HttpResponse?]()

    override public func dispatch(_ request: HttpRequest) -> ([String: String], (HttpRequest) -> HttpResponse) {
        for layer in middleware {
            if let response = layer(request) {
                return ([:], { _ in response })
            }
        }
        if let result = router.route(request.method, path: request.path) {
            return result
        }
        if let notFoundHandler = self.notFoundHandler {
            return ([:], notFoundHandler)
        }
        return super.dispatch(request)
    }

    public struct MethodRoute {
        public let method: String
        public let router: HttpRouter
        public subscript(path: String) -> ((HttpRequest) -> HttpResponse)? {
            set {
                router.register(method, path: path, handler: newValue)
            }
            get { return nil }
        }
    }
}
