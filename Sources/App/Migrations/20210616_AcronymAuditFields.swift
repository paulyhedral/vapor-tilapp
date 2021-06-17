//
// Created by Paul Schifferer on 6/16/21.
//

import Fluent


struct AcronymAuditFields : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        database.schema(Acronym.v20210601.schemaName)
                .field(Acronym.v20210616.createdAt, .datetime, .required)
                .field(Acronym.v20210616.updatedAt, .datetime, .required)
                .update()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        database.schema(Acronym.v20210601.schemaName)
                .deleteField(Acronym.v20210616.createdAt)
                .deleteField(Acronym.v20210616.updatedAt)
                .update()
    }
}
