//
// AcronymCategoryPivot.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Foundation

final class AcronymCategoryPivot: Model {
    static let schema = "acronym_categories"

    @ID
    var id: UUID?

    @Parent(key: "acronymId")
    var acronym: Acronym

    @Parent(key: "categoryId")
    var category: Category

    // MARK: Lifecycle

    init() {}

    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        $acronym.id = try acronym.requireID()
        $category.id = try category.requireID()
    }

    // MARK: Internal

}
