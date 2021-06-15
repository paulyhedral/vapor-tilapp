//
// UserTests.swift
// Copyright (c) 2021 Paul Schifferer.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users"
    var app: Application!

    override func setUpWithError() throws {
        self.app = try Application.testable()
    }

    override func tearDownWithError() throws {
        self.app.shutdown()
    }

    func testUsersCanBeRetrievedFromAPI() throws {
        let user = try User.create(name: self.usersName, username: self.usersUsername,
                                   on: self.app.db)
        _ = try User.create(on: self.app.db)

        try self.app.test(.GET, "/api/users", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)

            let users = try response.content.decode([User].self)

            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, usersName)
            XCTAssertEqual(users[0].username, usersUsername)
            XCTAssertEqual(users[0].id, user.id)
        })
    }

    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: usersName, username: usersUsername, password: "xyz123")

        try app.test(.POST, self.usersURI,
                     beforeRequest: { req in
                         try req.content.encode(user)
                     },
                     afterResponse: { response in
                         let receivedUser = try response.content.decode(User.self)
                         XCTAssertEqual(receivedUser.name, usersName)
                         XCTAssertEqual(receivedUser.username, usersUsername)
                         XCTAssertNotNil(receivedUser.id)

                         try app.test(.GET, usersURI,
                                      afterResponse: { secondResponse in
                                          let users = try secondResponse.content.decode([User].self)
                                          XCTAssertEqual(users.count, 1)
                                          XCTAssertEqual(users[0].name, usersName)
                                          XCTAssertEqual(users[0].username, usersUsername)
                                          XCTAssertEqual(users[0].id, receivedUser.id)
                                      })
                     })
    }

    func testGettingASingleUserFromTheAPI() throws {
        let user = try User.create(name: self.usersName, username: self.usersUsername, on: self.app.db)

        try self.app.test(.GET, "\(self.usersURI)\(user.id!)",
                          afterResponse: { response in
                              let receivedUser = try response.content.decode(User.self)

                              XCTAssertEqual(receivedUser.name, usersName)
                              XCTAssertEqual(receivedUser.username, usersUsername)
                              XCTAssertEqual(receivedUser.id, user.id)
                          })
    }

    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: self.app.db)

        let acronymShort = "OMG"
        let acronymLong = "On Mer Garsh"

        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: self.app.db)
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: self.app.db)

        try self.app.test(.GET, "\(self.usersURI)\(user.id!)/acronyms",
                          afterResponse: { response in
                              let acronyms = try response.content.decode([Acronym].self)

                              XCTAssertEqual(acronyms.count, 2)
                              XCTAssertEqual(acronyms[0].id, acronym1.id)
                              XCTAssertEqual(acronyms[0].short, acronymShort)
                              XCTAssertEqual(acronyms[0].long, acronymLong)
                          })
    }
}
