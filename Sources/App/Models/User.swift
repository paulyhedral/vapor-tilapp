//
// User.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor


final class User : Model {
    static let schema = "users"

    @ID
    var id : UUID?

    @Field(key: "name")
    var name : String

    @Field(key: "username")
    var username : String

//    @Field(key: "password")
//    var password : String

    @Children(for: \.$user)
    var acronyms : [Acronym]

    @OptionalField(key: "thirdPartyAuth")
    var thirdPartyAuth : String?

    @OptionalField(key: "thirdPartyAuthId")
    var thirdPartyAuthId : String?

    @Field(key: "email")
    var email : String

    // MARK: Lifecycle

    init() {
    }

    init(id : UUID? = nil, name : String, username : String, // password : String,
         thirdPartyAuth : String? = nil, thirdPartyAuthId : String? = nil,
         email : String) {
        self.id = id
        self.name = name
        self.username = username
//        self.password = password
        self.thirdPartyAuth = thirdPartyAuth
        self.thirdPartyAuthId = thirdPartyAuthId
        self.email = email
    }

    // MARK: Internal

    final class Public : Content {
        // MARK: Lifecycle

        init(id : UUID?, name : String, username : String) {
            self.id = id
            self.name = name
            self.username = username
        }

        // MARK: Internal

        var id : UUID?
        var name : String
        var username : String
    }
}

extension User : Content {}

extension User {
    func convertToPublic() -> User.Public {
        User.Public(id: self.id, name: self.name, username: self.username)
    }
}

extension EventLoopFuture where Value : User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        map { user in
            user.convertToPublic()
        }
    }
}

extension Collection where Element : User {
    func convertToPublic() -> [User.Public] {
        map {
            $0.convertToPublic()
        }
    }
}

extension EventLoopFuture where Value == [User] {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        map {
            $0.convertToPublic()
        }
    }
}


//extension User : ModelAuthenticatable {
//    static let usernameKey = \User.$username
//    static let passwordHashKey = \User.$password
//
//    func verify(password : String) throws -> Bool {
//        try Bcrypt.verify(password, created: self.password)
//    }
//}


extension User : ModelSessionAuthenticatable {}


//extension User : ModelCredentialsAuthenticatable {}
