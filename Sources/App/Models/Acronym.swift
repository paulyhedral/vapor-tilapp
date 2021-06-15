//
// Acronym.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor

// MARK: - Acronym

final class Acronym: Model {
    // MARK: Internal

    static let schema = "acronyms"

    @ID
    var id: UUID?

    @Field(key: "short")
    var short: String

    @Field(key: "long")
    var long: String

    @Parent(key: "userId")
    var user: User

    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories: [Category]

    // MARK: Lifecycle

    init() {}

    init(id: UUID? = nil, short: String, long: String, userId: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        $user.id = userId
    }
}

// MARK: Content

extension Acronym: Content {}
