//
// Token.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor

// MARK: - Token

final class Token: Model {
    static let schema = "tokens"

    @ID
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "userId")
    var user: User

    // MARK: Lifecycle

    init() {}

    init(id: UUID? = nil, value: String, userId: User.IDValue) {
        self.id = id
        self.value = value
        $user.id = userId
    }

    // MARK: Internal

}

// MARK: Content

extension Token: Content {}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = [UInt8].random(count: 56).base64
        return try Token(value: random, userId: user.requireID())
    }
}

// MARK: ModelTokenAuthenticatable

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    typealias User = App.User

    var isValid: Bool {
        true
    }
}
