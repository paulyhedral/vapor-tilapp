//
// TokenMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent


struct CreateTokenTable : Migration {
    func prepare(on database : Database) -> EventLoopFuture<Void> {
        database.schema(Token.v20210601.schemaName)
                .id()
                .field(Token.v20210601.value, .string, .required)
                .field(Token.v20210601.userId, .uuid, .required, .references(User.v20210601.schemaName, User.v20210601.id, onDelete: .cascade))
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<Void> {
        database.schema(Token.v20210601.schemaName)
                .delete()
    }
}

extension Token {
    enum v20210601 {
        static let schemaName = "tokens"
        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let userId = FieldKey(stringLiteral: "userId")
    }
}
