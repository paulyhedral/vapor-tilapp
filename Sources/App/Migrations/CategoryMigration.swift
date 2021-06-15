//
// CategoryMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent

struct CategoryMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema).delete()
    }
}
