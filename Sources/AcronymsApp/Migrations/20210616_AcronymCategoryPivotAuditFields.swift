//
// Created by Paul Schifferer on 6/16/21.
//

import Fluent


struct AcronymCategoryPivotAuditFields : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        database.schema(AcronymCategoryPivot.v20210601.schemaName)
                .field(AcronymCategoryPivot.v20210616.createdAt, .datetime, .required)
                .field(AcronymCategoryPivot.v20210616.updatedAt, .datetime, .required)
                .update()
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        database.schema(AcronymCategoryPivot.v20210601.schemaName)
                .deleteField(AcronymCategoryPivot.v20210616.createdAt)
                .deleteField(AcronymCategoryPivot.v20210616.updatedAt)
                .update()
    }
}
