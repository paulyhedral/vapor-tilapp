//
// Created by Paul Schifferer on 6/16/21.
//

import Fluent


extension User {
    enum v20210616 {
        static let twitterURL = FieldKey(stringLiteral: "twitterURL")
        static let deletedAt = FieldKey(stringLiteral: "deletedAt")
        static let createdAt = FieldKey(stringLiteral: "createdAt")
        static let updatedAt = FieldKey(stringLiteral: "updatedAt")
    }
}
