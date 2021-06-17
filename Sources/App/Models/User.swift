//
// User.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor


final class User : Model {
    static let schema = User.v20210601.schemaName

    @ID
    var id : UUID?

    @Timestamp(key: User.v20210616.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: User.v20210616.updatedAt, on: .update)
    var updatedAt: Date?

    @Field(key: User.v20210601.name)
    var name : String

    @Field(key: User.v20210601.username)
    var username : String

//    @Field(key: "password")
//    var password : String

    @Children(for: \.$user)
    var acronyms : [Acronym]

    @Timestamp(key: User.v20210616.deletedAt, on: .delete)
    var deletedAt : Date?

    @OptionalField(key: User.v20210601.thirdPartyAuth)
    var thirdPartyAuth : String?

    @OptionalField(key: User.v20210601.thirdPartyAuthId)
    var thirdPartyAuthId : String?

    @Field(key: User.v20210601.email)
    var email : String

    @OptionalField(key: User.v20210601.profilePicture)
    var profilePicture : String?

    @OptionalField(key: User.v20210616.twitterURL)
    var twitterURL : String?

    init() {
    }

    init(id : UUID? = nil, name : String, username : String, // password : String,
         thirdPartyAuth : String? = nil, thirdPartyAuthId : String? = nil,
         email : String, profilePicture : String? = nil,
         twitterURL : String? = nil) {
        self.id = id
        self.name = name
        self.username = username
//        self.password = password
        self.thirdPartyAuth = thirdPartyAuth
        self.thirdPartyAuthId = thirdPartyAuthId
        self.email = email
        self.profilePicture = profilePicture
        self.twitterURL = twitterURL
    }

    final class Public : Content {
        var id : UUID?
        var name : String
        var username : String
        var twitterURL : String?

        init(id : UUID?, name : String, username : String, twitterURL : String? = nil) {
            self.id = id
            self.name = name
            self.username = username
            self.twitterURL = twitterURL
        }
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
