//
// Created by Paul Schifferer on 6/16/21.
//

import Fluent


struct MakeCategoriesUnique : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        database.schema(Category.v20210601.schemaName)
                .unique(on: Category.v20210601.name)
                .update()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        database.schema(Category.v20210601.schemaName)
                .deleteUnique(on: Category.v20210601.name)
                .update()
    }
}
