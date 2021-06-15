//
// AcronymCategoryPivotMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent

struct AcronymCategoryPivotMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymCategoryPivot.schema)
            .id()
            .field("acronymId", .uuid, .required,
                   .references(Acronym.schema, "id", onDelete: .cascade))
                .field("categoryId", .uuid, .required,
                       .references(Category.schema, "id", onDelete: .cascade))
                    .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AcronymCategoryPivot.schema)
            .delete()
    }
}
