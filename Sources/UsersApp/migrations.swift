//
// Created by Paul Schifferer on 6/16/21.
//

import Vapor
import Fluent


public func migrations(_ app : Application) throws {
    app.migrations.add(CreateUserTable())
    app.migrations.add(CreateTokenTable())
    app.migrations.add(SeedDatabase())
    app.migrations.add(AddTwitterHandle())
    app.migrations.add(SoftDeleteUser())
    app.migrations.add(UserAuditFields())
    app.migrations.add(TokenAuditFields())

    switch app.environment {
    case .development, .testing:
        // TODO: non-production migrations
        break
    default:
        break
    }

    app.migrations.add(CacheEntry.migration)
}
