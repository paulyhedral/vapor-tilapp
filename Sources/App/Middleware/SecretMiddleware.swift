//
// Created by Paul Schifferer on 6/16/21.
//

import Foundation
import Vapor


final class SecretHeaderMiddleware : Middleware {
    let header : String
    let secret : String

    init(header : String = "X-Secret", secret : String) {
        self.header = header
        self.secret = secret
    }

    func respond(to request : Request, chainingTo next : Responder) -> EventLoopFuture<Response> {
        guard let secretValue = request.headers.first(name: header) else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Missing '\(header)' header."))
        }
        guard request.headers.first(name: header) == secret else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Incorrect '\(header)' header."))
        }

        return next.respond(to: request)
    }
}

extension SecretHeaderMiddleware {
    static func detect() throws -> Self {
        guard let value = Environment.get("SECRET_VALUE") else {
            throw Abort(.internalServerError, reason: "No SECRET_VALUE set in environment!")
        }

        return .init(header: Environment.get("SECRET_HEADER") ?? "X-Secret", secret: value)
    }
}
