//
// CategoryMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent


struct CreateCategoryTable : Migration {
    func prepare(on database : Database) -> EventLoopFuture<Void> {
        database.schema(Category.v20210601.schemaName)
                .id()
                .field(Category.v20210601.name, .string, .required)
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<Void> {
        database.schema(Category.v20210601.schemaName)
                .delete()
    }
}

extension Category {
    enum v20210601 {
        static let schemaName = "categories"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
    }
}
