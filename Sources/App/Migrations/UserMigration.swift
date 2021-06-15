//
// UserMigration.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent


struct UserMigration : Migration {
    func prepare(on database : Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
                .id()
                .field("name", .string, .required)
                .field("username", .string, .required)
//                .field("password", .string, .required)
                .field("thirdPartyAuth", .string)
                .field("thirdPartyAuthId", .string)
                .field("email", .string, .required)
                .unique(on: "username")
                .unique(on: "email")
                .create()
    }

    func revert(on database : Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
                .delete()
    }
}
