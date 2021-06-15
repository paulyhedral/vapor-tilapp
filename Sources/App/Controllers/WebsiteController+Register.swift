//
// WebsiteController+Register.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Leaf
import Vapor


extension WebsiteController {
    func registerHandler(_ req : Request) throws -> EventLoopFuture<View> {
        let context : RegisterContext
        if let message = req.query[String.self, at: "message"] {
            context = RegisterContext(message: message)
        }
        else {
            context = RegisterContext()
        }

        return req.view.render("register", context)
    }

    func registerPostHandler(_ req : Request) throws -> EventLoopFuture<Response> {
        do {
            try RegisterData.validate(content: req)
        }
        catch let error as ValidationsError {
            let message = error.description
                                  .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Unknown error"
            let redirect = req.redirect(to: "/register?message=\(message)")
            return req.eventLoop.future(redirect)
        }

        let data = try req.content.decode(RegisterData.self)
        let password = try Bcrypt.hash(data.password)
        let user = User(name: data.name, username: data.username, password: password, email: data.emailAddress)

        return user.save(on: req.db)
                   .map {
                       req.auth.login(user)
                       return req.redirect(to: "/")
                   }
    }
}

struct RegisterContext : Encodable {

    init(message : String? = nil) {
        self.message = message
    }

    let title = "Register"
    let message : String?
}

struct RegisterData : Content {
    let name : String
    let username : String
    let password : String
    let confirmPassword : String
    let emailAddress : String
}
