//
// CategoriesController.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Vapor


struct CategoriesController : RouteCollection {
    static let endpointPath : PathComponent = "categories"

    func boot(routes : RoutesBuilder) throws {
        let group = routes.grouped(Constants.apiPath, Self.endpointPath)

        group.get(use: self.getAllHandler)
        group.get(":categoryId", use: self.getHandler)
        group.get(":categoryId", "acronyms", use: self.getAcronymsHandler)

        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let protected = group.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        protected.post(use: self.createHandler)
    }

    func createHandler(_ req : Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
//        let user = try req.auth.require(User.self)
        return category.save(on: req.db)
                       .map {
                           category
                       }
    }

    func getAllHandler(_ req : Request) -> EventLoopFuture<[Category]> {
        Category.query(on: req.db)
                .all()
    }

    func getHandler(_ req : Request) -> EventLoopFuture<Category> {
        Category.find(req.parameters.get("categoryId"),
                        on: req.db)
                .unwrap(or: Abort(.notFound))
    }

    func getAcronymsHandler(_ req : Request) -> EventLoopFuture<[Acronym]> {
        Category.find(req.parameters.get("categoryId"),
                        on: req.db)
                .unwrap(or: Abort(.notFound))
                .flatMap { category in
                    category.$acronyms.get(on: req.db)
                }
    }
}
