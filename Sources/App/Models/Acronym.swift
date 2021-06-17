//
// Acronym.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor


final class Acronym : Model {

    static let schema = Acronym.v20210601.schemaName

    @ID
    var id : UUID?

    @Timestamp(key: Acronym.v20210616.createdAt, on: .create)
    var createdAt : Date?

    @Timestamp(key: Acronym.v20210616.updatedAt, on: .update)
    var updatedAt : Date?

    @Field(key: Acronym.v20210601.short)
    var short : String

    @Field(key: Acronym.v20210601.long)
    var long : String

    @Parent(key: Acronym.v20210601.userId)
    var user : User

    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories : [Category]

    init() {
    }

    init(id : UUID? = nil, short : String, long : String, userId : User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userId
    }
}

extension Acronym : Content {}
