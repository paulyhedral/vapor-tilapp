import Vapor
import Leaf


extension WebsiteController {

    func loginHandler(_ req : Request) throws -> EventLoopFuture<View> {
        let context : LoginContext

        if let error = req.query[Bool.self, at: "error"], error {
            context = LoginContext(loginError: true)
        }
        else {
            context = LoginContext()
        }

        return req.view.render("login", context)
    }

    func loginPostHandler(_ req : Request) throws -> EventLoopFuture<Response> {
        if req.auth.has(User.self) {
            return req.eventLoop.future(req.redirect(to: "/"))
        }
        else {
            let context = LoginContext(loginError: true)
            return req.view
                    .render("login", context)
                    .encodeResponse(for: req)
        }
    }

    func logoutHandler(_ req : Request) throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }

}

struct LoginContext : Encodable {
    let title = "Log In"
    let loginError : Bool

    init(loginError : Bool = false) {
        self.loginError = loginError
    }
}
