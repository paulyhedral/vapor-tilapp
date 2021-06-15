//
// WebsiteController+User.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Leaf
import Vapor

extension WebsiteController {
    func userHandler(_ req: Request) -> EventLoopFuture<View> {
        User.find(req.parameters.get("userId"),
                  on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
                    .flatMap { acronyms in
                        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                        return req.view.render("user", context)
                    }
            }
    }

    func allUsersHandler(_ req: Request) -> EventLoopFuture<View> {
        User.query(on: req.db)
            .all()
            .flatMap { users in
                let context = AllUsersContext(title: "All Users", users: users)
                return req.view.render("allUsers", context)
            }
    }
}

// MARK: - UserContext

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]
}

// MARK: - AllUsersContext

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}
