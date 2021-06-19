//
// AcronymsController.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor


struct AcronymsController: RouteCollection {
    static let endpointPath: PathComponent = "acronyms"

    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped(Constants.apiPath, Self.endpointPath)

        group.get(use: self.getAllHandler)
        group.get(":acronymId", use: self.getHandler)
        group.get("search", use: self.searchHandler)
        group.get("first", use: self.getFirstHandler)
        group.get("sorted", use: self.sortedHandler)
//        group.get(":acronymId", "user", use: self.getUserHandler)
        group.get(":acronymId", "categories", use: self.getCategoriesHandler)

//        let tokenAuthMiddleware = Token.authenticator()
//        let guardAuthMiddleware = User.guardMiddleware()
//        let protected = group.grouped(tokenAuthMiddleware, guardAuthMiddleware)
//        protected.post(use: self.createHandler)
//        protected.put(":acronymId", use: self.updateHandler)
//        protected.delete(":acronymId", use: self.deleteHandler)
//        protected.post(":acronymId", "categories", ":categoryId", use: self.addCategoriesHandler)
//        protected.delete(":acronymId", "categories", ":categoryId", use: self.removeCategoriesHandler)
    }

    func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }

    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let user = try req.auth.require(User.self)
        let acronym = Acronym(short: data.short,
                              long: data.long,
                              userId: try user.requireID())
        return acronym.save(on: req.db).map {
            acronym
        }
    }

    func getHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymId"),
                     on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        return Acronym.find(req.parameters.get("acronymId"),
                            on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = data.short
                acronym.long = data.long
                acronym.$user.id = userId
                return acronym.save(on: req.db)
                    .map { acronym }
            }
    }

    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("acronymId"),
                     on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }

        return Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }
            .all()
    }

    func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    func sortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }

    func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get("acronymId"),
                     on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }

    func addCategoriesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymId"),
                                        on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get("categoryId"),
                                          on: req.db)
            .unwrap(or: Abort(.notFound))

        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym.$categories
                    .attach(category, on: req.db)
                    .transform(to: .created)
            }
    }

    func removeCategoriesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymId"),
                                        on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get("categoryId"),
                                          on: req.db)
            .unwrap(or: Abort(.notFound))

        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym.$categories
                    .detach(category, on: req.db)
                    .transform(to: .noContent)
            }
    }

    func getCategoriesHandler(_ req: Request) -> EventLoopFuture<[Category]> {
        Acronym.find(req.parameters.get("acronymId"),
                     on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$categories.query(on: req.db)
                    .all()
            }
    }
}


struct CreateAcronymData: Content {
    let short: String
    let long: String
}
