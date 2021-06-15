//
// AcronymMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent

struct AcronymMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Acronym.schema)
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userId", .uuid, .required, .references(User.schema, "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Acronym.schema)
            .delete()
    }
}
