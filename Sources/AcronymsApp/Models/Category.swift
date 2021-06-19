//
// Category.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor


final class Category : Model {
    static let schema = Category.v20210601.schemaName

    @ID
    var id : UUID?

    @Timestamp(key: Category.v20210616.createdAt, on: .create)
    var createdAt : Date?

    @Timestamp(key: Category.v20210616.updatedAt, on: .update)
    var updatedAt : Date?

    @Field(key: Category.v20210601.name)
    var name : String

//    @Parent(key: "userId")
//    var user : User

    @Siblings(through: AcronymCategoryPivot.self, from: \.$category, to: \.$acronym)
    var acronyms : [Acronym]

    init() {
    }

    init(id : UUID? = nil, name : String /* , userId : User.IDValue */) {
        self.id = id
        self.name = name
//        self.$user.id = userId
    }
}

extension Category : Content {}

extension Category {
    static func addCategory(_ name : String, to acronym : Acronym, on req : Request) -> EventLoopFuture<Void> {
        Category.query(on: req.db)
                .filter(\.$name == name)
                .first()
                .flatMap { foundCategory in
                    if let existingCategory = foundCategory {
                        return acronym.$categories
                                .attach(existingCategory, on: req.db)
                    }
                    else {
//                               let user = try req.auth.require(User.self)
                        let category = Category(name: name /* , userId: try user.requireID() */)
                        return category.save(on: req.db)
                                       .flatMap {
                                           acronym.$categories
                                                   .attach(category, on: req.db)
                                       }
                    }
                }
    }
}
