//
// configure.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import FluentMongoDriver
import Leaf
import Vapor
import SendGrid
import Redis


// configures your application
public func configure(_ app : Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(LogRequestMiddleware())

    guard let dbUrl = Environment.get("DATABASE_URL") else {
        fatalError("DATABASE_URL is not set in environment")
    }
//    print("dbUrl: \(String(describing: dbUrl))")
    try app.databases.use(.mongo(connectionString: dbUrl), as: .mongo)

    let redisHostname = Environment.get("REDIS_HOSTNAME") ?? "localhost"
    let redisConfig = try RedisConfiguration(hostname: redisHostname)
    app.redis.configuration = redisConfig

    try migrations(app)

    app.views.use(.leaf)
    app.sessions.use(.redis)
    app.caches.use(.fluent)

    // register routes
    try routes(app)

    app.sendgrid.initialize()
}
