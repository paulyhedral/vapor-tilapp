import Fluent


struct AddTwitterHandle : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        database.schema(User.v20210601.schemaName)
                .field(User.v20210616.twitterURL, .string)
                .update()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        database.schema(User.v20210601.schemaName)
                .deleteField(User.v20210616.twitterURL)
                .update()
    }
}
