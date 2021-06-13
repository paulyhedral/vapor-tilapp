import Fluent


struct UserMigration : Migration {

    func prepare(on database : Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
                .id()
                .field("name", .string, .required)
                .field("username", .string, .required)
                .field("password", .string, .required)
                .field("thirdPartyAuth", .string)
                .field("thirdPartyAuthId", .string)
                .unique(on: "username")
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
                .delete()
    }
}
