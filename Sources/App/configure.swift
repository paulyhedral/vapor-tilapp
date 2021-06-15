//
// configure.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import FluentMongoDriver
import Leaf
import Vapor
import SendGrid

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)

    guard let dbUrl = Environment.get("DATABASE_URL") else {
        fatalError("DATABASE_URL is not set in environment")
    }
//    print("dbUrl: \(String(describing: dbUrl))")
    try app.databases.use(.mongo(connectionString: dbUrl), as: .mongo)

    app.migrations.add(AcronymMigration())
    app.migrations.add(UserMigration())
    app.migrations.add(CategoryMigration())
    app.migrations.add(AcronymCategoryPivotMigration())
    app.migrations.add(TokenMigration())
    app.migrations.add(SeedDatabase())
    app.migrations.add(ResetPasswordTokenMigration())
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()

    app.views.use(.leaf)

    // register routes
    try routes(app)

    app.sendgrid.initialize()
}
