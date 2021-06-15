//
// Created by Paul Schifferer on 6/15/21.
//

import Vapor
import Fluent


final class ResetPasswordToken : Model {
    static let schema = "resetPasswordTokens"

    @ID
    var id : UUID?

    @Field(key: "token")
    var token : String

    @Parent(key: "userId")
    var user : User

    init() {
    }

    init(id : UUID? = nil, token : String, userId : User.IDValue) {
        self.id = id
        self.token = token
        self.$user.id = userId
    }
}

extension ResetPasswordToken : Content {}
