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
public func configure(_ app : Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)

    guard let dbUrl = Environment.get("DATABASE_URL") else {
        fatalError("DATABASE_URL is not set in environment")
    }
//    print("dbUrl: \(String(describing: dbUrl))")
    try app.databases.use(.mongo(connectionString: dbUrl), as: .mongo)

    try migrations(app)

    app.views.use(.leaf)

    // register routes
    try routes(app)

    app.sendgrid.initialize()
}
