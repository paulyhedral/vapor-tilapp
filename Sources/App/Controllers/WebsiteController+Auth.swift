//
// WebsiteController+Auth.swift
// Copyright (c) 2021 Paul Schifferer.
//

//import ImperialAuth0
import Leaf
import Vapor


extension WebsiteController {
    func loginHandler(_ req : Request) throws -> EventLoopFuture<View> {
        let context : LoginContext

        if let error = req.query[Bool.self, at: "error"], error {
            context = LoginContext(loginError: "\(error)")
        }
        else {
            context = LoginContext()
        }

        return req.view.render("login", context)
    }
//
//    //   func loginAuth0Handler(_ req: Request) throws -> EventLoopFuture<Response> {
//    //     let auth = Auth0Auth()
//    //     return req.redirect(to: auth.authURL)
//    //   }
//
//    func loginPostHandler(_ req : Request) throws -> EventLoopFuture<Response> {
//        if req.auth.has(User.self) {
//            return req.eventLoop.future(req.redirect(to: "/"))
//        }
//        else {
//            let context = LoginContext(loginError: "TODO")
//            return req.view
//                    .render("login", context)
//                    .encodeResponse(for: req)
//        }
//    }

    func logoutHandler(_ req : Request) throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }

}


struct LoginContext : Encodable {

    init(loginError : String? = nil) {
        self.loginError = loginError
    }

    let title = "Log In"
    let loginError : String?
}
