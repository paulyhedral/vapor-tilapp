import Fluent
import Foundation
import Fluent
import Vapor


struct SeedDatabase : Migration {
    func prepare(on database : Database) -> EventLoopFuture<()> {
        let passwordHash : String
        do {
            let password = [ UInt8 ].random(count: 32).map {
                $0 % 32
            }.base64
            print("admin password: \(password)")
            passwordHash = try Bcrypt.hash(password)
        }
        catch {
            return database.eventLoop.future(error: error)
        }

        let user = User(name: "Admin", username: "admin", password: passwordHash)
        return user.save(on: database)
    }

    func revert(on database : Database) -> EventLoopFuture<()> {
        User.query(on: database)
            .filter(\.$username == "admin")
            .delete()
    }
}
