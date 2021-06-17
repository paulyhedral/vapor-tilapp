//
// Category.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Fluent
import Vapor


extension Category {
    enum v20210616 {
        static let createdAt = FieldKey(stringLiteral: "createdAt")
        static let updatedAt = FieldKey(stringLiteral: "updatedAt")
    }
}
