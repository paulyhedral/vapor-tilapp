//
// Created by Paul Schifferer on 6/15/21.
//

import Fluent


struct ResetPasswordTokenMigration : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        database.schema(ResetPasswordToken.schema)
                .id()
                .field("token", .string, .required)
                .field("userId", .uuid, .required, .references(User.schema, "id"))
                .unique(on: "token")
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        database.schema(ResetPasswordToken.schema)
                .delete()
    }
}
