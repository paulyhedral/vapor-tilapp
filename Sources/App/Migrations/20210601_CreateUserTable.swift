//
// 20210601_CreateUserTable.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent


struct CreateUserTable : Migration {
    func prepare(on database : Database) -> EventLoopFuture<Void> {
        database.schema(User.v20210601.schemaName)
                .id()
                .field(User.v20210601.name, .string, .required)
                .field(User.v20210601.username, .string, .required)
                //                .field("password", .string, .required)
                .field(User.v20210601.thirdPartyAuth, .string)
                .field(User.v20210601.thirdPartyAuthId, .string)
                .field(User.v20210601.email, .string, .required)
                .field(User.v20210601.profilePicture, .string)
                .unique(on: User.v20210601.username)
                .unique(on: User.v20210601.email)
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<Void> {
        database.schema(User.v20210601.schemaName)
                .delete()
    }
}

extension User {
    enum v20210601 {
        static let schemaName = "users"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let username = FieldKey(stringLiteral: "username")
        static let thirdPartyAuth = FieldKey(stringLiteral: "thirdPartyAuth")
        static let thirdPartyAuthId = FieldKey(stringLiteral: "thirdPartyAuthId")
        static let email = FieldKey(stringLiteral: "email")
        static let profilePicture = FieldKey(stringLiteral: "profilePicture")
    }
}
