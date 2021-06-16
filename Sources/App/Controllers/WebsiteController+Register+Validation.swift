//
// WebsiteController+Register+Validation.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Leaf
import Vapor


//extension RegisterData: Validatable {
//    public static func validations(_ validations: inout Validations) {
//        validations.add("name", as: String.self, is: .ascii)
//        validations.add("username", as: String.self, is: .alphanumeric && .count(3...))
//        validations.add("password", as: String.self, is: .count(8...))
//        validations.add("zipCode", as: String.self, is: .zipCode, required: false)
//        validations.add("emailAddress", as: String.self, is: .email)
//    }
//}
//
//extension ValidatorResults {
//    struct ZipCode {
//        let isValidZipCode: Bool
//    }
//}
//
//
//extension ValidatorResults.ZipCode: ValidatorResult {
//    var isFailure: Bool {
//        !isValidZipCode
//    }
//
//    var successDescription: String? {
//        "is a valid zip code"
//    }
//
//    var failureDescription: String? {
//        "is not a valid zip code"
//    }
//}
//
//extension Validator where T == String {
//    private static var zipCodeRegex: String {
//        "^\\d{5}(?:[-\\s]\\d{4})?$"
//    }
//
//    public static var zipCode: Validator<T> {
//        Validator { input -> ValidatorResult in
//            guard let range = input.range(of: zipCodeRegex, options: [.regularExpression]),
//                  range.lowerBound == input.startIndex, range.upperBound == input.endIndex else
//            {
//                return ValidatorResults.ZipCode(isValidZipCode: false)
//            }
//
//            return ValidatorResults.ZipCode(isValidZipCode: true)
//        }
//    }
//}
