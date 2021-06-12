import Fluent


struct TokenMigration : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        database.schema(Token.schema)
                .id()
                .field("value", .string, .required)
                .field("userId", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        database.schema(Token.schema)
                .delete()
    }
}
