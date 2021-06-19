//
// Created by Paul Schifferer on 6/16/21.
//

import Fluent


struct CategoryAuditFields : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
                database.schema(Category.v20210601.schemaName)
                             .field(Category.v20210616.createdAt, .datetime, .required)
                             .field(Category.v20210616.updatedAt, .datetime, .required)
                             .update()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
                database.schema(Category.v20210601.schemaName)
                             .deleteField(Category.v20210616.createdAt)
                             .deleteField(Category.v20210616.updatedAt)
                             .update()
    }
}
