//
// WebsiteController.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Leaf
import Vapor


struct WebsiteController : RouteCollection {
    func boot(routes : RoutesBuilder) throws {
        let authSessionRoutes = routes.grouped(User.sessionAuthenticator())
        authSessionRoutes.get("auth", "login", use: loginHandler)
        // authSessionRoutes.get("login", "auth0", use: loginAuth0Handler)

//        let credentialsAuthRoutes = authSessionRoutes.grouped(User.credentialsAuthenticator())
//        credentialsAuthRoutes.post("auth", "login", use: loginPostHandler)

        authSessionRoutes.post("auth", "logout", use: logoutHandler)
//        authSessionRoutes.get("auth", "register", use: registerHandler)
//        authSessionRoutes.post("auth", "register", use: registerPostHandler)
//        authSessionRoutes.get("auth", "password", "forgot", use: forgottenPasswordHandler)
//        authSessionRoutes.post("auth", "password", "reset", use: forgottenPasswordPostHandler)
//        authSessionRoutes.get("resetPassword", use: resetPasswordHandler)

        authSessionRoutes.get(use: indexHandler)
        authSessionRoutes.get("acronyms", ":acronymId", use: acronymHandler)
        authSessionRoutes.get("users", ":userId", use: userHandler)
        authSessionRoutes.get("users", use: allUsersHandler)
        authSessionRoutes.get("categories", use: allCategoriesHandler)
        authSessionRoutes.get("categories", ":categoryId", use: categoryHandler)

        let protectedRoutes = authSessionRoutes.grouped(User.redirectMiddleware(path: "/auth/login"))
        protectedRoutes.get("acronyms", "create", use: createAcronymHandler)
        protectedRoutes.post("acronyms", "create", use: createAcronymPostHandler)
        protectedRoutes.get("acronyms", ":acronymId", "edit", use: editAcronymHandler)
        protectedRoutes.post("acronyms", ":acronymId", "edit", use: editAcronymPostHandler)
        protectedRoutes.post("acronyms", ":acronymId", "delete", use: deleteAcronymHandler)
    }
}
