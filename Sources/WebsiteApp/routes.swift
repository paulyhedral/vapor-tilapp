//
// routes.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: AcronymsController())
    try app.register(collection: UsersController())
    try app.register(collection: CategoriesController())
    try app.register(collection: WebsiteController())
    try app.register(collection: AuthController())
    try app.register(collection: HealthController())
}
