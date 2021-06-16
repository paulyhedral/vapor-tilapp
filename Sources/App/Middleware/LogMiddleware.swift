//
// Created by Paul Schifferer on 6/16/21.
//

import Vapor


final class LogMiddleware : Middleware {
    func respond(to request : Request, chainingTo next : Responder) -> EventLoopFuture<Response> {
        request.logger.info("\(request)")
        return next.respond(to: request)
    }
}
