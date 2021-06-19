//
// AcronymCategoryPivot.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Foundation


final class AcronymCategoryPivot : Model {
    static let schema = AcronymCategoryPivot.v20210601.schemaName

    @ID
    var id : UUID?

    @Timestamp(key: AcronymCategoryPivot.v20210616.createdAt, on: .create)
    var createdAt : Date?

    @Timestamp(key: AcronymCategoryPivot.v20210616.updatedAt, on: .update)
    var updatedAt : Date?

    @Parent(key: AcronymCategoryPivot.v20210601.acronymId)
    var acronym : Acronym

    @Parent(key: AcronymCategoryPivot.v20210601.categoryId)
    var category : Category

    init() {
    }

    init(id : UUID? = nil, acronym : Acronym, category : Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}
