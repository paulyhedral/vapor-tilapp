import Vapor
import Fluent


final class Token : Model {
    static let schema = "tokens"

    @ID
    var id : UUID?

    @Field(key: "value")
    var value : String

    @Parent(key: "userId")
    var user : User

    init() {
    }

    init(id : UUID? = nil, value : String, userId : User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userId
    }
}

extension Token : Content {}

extension Token {
    static func generate(for user : User) throws -> Token {
        let random = [ UInt8 ].random(count: 56).base64
        return try Token(value: random, userId: user.requireID())
    }
}

extension Token : ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    typealias User = App.User

    var isValid : Bool {
        true
    }
}
