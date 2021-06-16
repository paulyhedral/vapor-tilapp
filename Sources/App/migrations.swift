//
// Created by Paul Schifferer on 6/16/21.
//

import Vapor
import Fluent


public func migrations(_ app : Application) throws {
    app.migrations.add(CreateAcronymTable())
    app.migrations.add(CreateUserTable())
    app.migrations.add(CreateCategoryTable())
    app.migrations.add(CreateAcronymCategoryPivotTable())
    app.migrations.add(CreateTokenTable())
    app.migrations.add(SeedDatabase())
//    app.migrations.add(CreateResetPasswordTokenTable())
    app.migrations.add(AddTwitterHandle())
    app.migrations.add(MakeCategoriesUnique())

    switch app.environment {
    case .development, .testing:
        // TODO: non-production migrations
        break
    default:
        break
    }

    app.migrations.add(CacheEntry.migration)

    app.logger.logLevel = .debug
    try app.autoMigrate().wait()
}
