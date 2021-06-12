import Fluent
import FluentMongoDriver
import Leaf
import Vapor


// configures your application
public func configure(_ app : Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)

    let dbUrl = Environment.get("DATABASE_URL")
    print("dbUrl: \(String(describing: dbUrl))")
    try app.databases.use(.mongo(
            connectionString: dbUrl ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo)

    app.migrations.add(AcronymMigration())
    app.migrations.add(UserMigration())
    app.migrations.add(CategoryMigration())
    app.migrations.add(AcronymCategoryPivotMigration())
    app.migrations.add(TokenMigration())
    app.migrations.add(SeedDatabase())
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
