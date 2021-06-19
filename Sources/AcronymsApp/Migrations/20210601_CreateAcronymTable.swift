//
// AcronymMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent


struct CreateAcronymTable : Migration {
    func prepare(on database : Database) -> EventLoopFuture<Void> {
        database.schema(Acronym.v20210601.schemaName)
                .id()
                .field(Acronym.v20210601.short, .string, .required)
                .field(Acronym.v20210601.long, .string, .required)
                .field(Acronym.v20210601.userId, .uuid, .required, .references(User.v20210601.schemaName, Acronym.v20210601.id))
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<Void> {
        database.schema(Acronym.v20210601.schemaName)
                .delete()
    }
}

extension Acronym {
    enum v20210601 {
        static let schemaName = "acronyms"
        static let id = FieldKey(stringLiteral: "id")
        static let short = FieldKey(stringLiteral: "short")
        static let long = FieldKey(stringLiteral: "long")
        static let userId = FieldKey(stringLiteral: "userId")
    }
}
