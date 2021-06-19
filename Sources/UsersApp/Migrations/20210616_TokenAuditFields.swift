//
// Created by Paul Schifferer on 6/16/21.
//

import Fluent


struct TokenAuditFields : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        database.schema(Token.v20210601.schemaName)
                .field(Token.v20210616.createdAt, .datetime, .required)
                .field(Token.v20210616.updatedAt, .datetime, .required)
                .update()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        database.schema(Token.v20210601.schemaName)
                .deleteField(Token.v20210616.createdAt)
                .deleteField(Token.v20210616.updatedAt)
                .update()
    }
}
