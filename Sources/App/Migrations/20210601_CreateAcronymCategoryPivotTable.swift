//
// AcronymCategoryPivotMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent


struct CreateAcronymCategoryPivotTable : Migration {
    func prepare(on database : Database) -> EventLoopFuture<Void> {
        database.schema(AcronymCategoryPivot.v20210601.schemaName)
                .id()
                .field(AcronymCategoryPivot.v20210601.acronymId, .uuid, .required,
                        .references(Acronym.schema, Acronym.v20210601.id, onDelete: .cascade))
                .field(AcronymCategoryPivot.v20210601.categoryId, .uuid, .required,
                        .references(Category.v20210601.schemaName, Category.v20210601.id, onDelete: .cascade))
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<Void> {
        database.schema(AcronymCategoryPivot.v20210601.schemaName)
                .delete()
    }
}

extension AcronymCategoryPivot {
    enum v20210601 {
        static let schemaName = "acronym_categories"
        static let id = FieldKey(stringLiteral: "id")
        static let acronymId = FieldKey(stringLiteral: "acronymId")
        static let categoryId = FieldKey(stringLiteral: "categoryId")
    }
}
