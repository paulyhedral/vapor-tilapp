import Vapor
import Fluent
import ImperialGoogle


struct AuthController : RouteCollection {

    func boot(routes : RoutesBuilder) throws {
        try addGoogle(routes: routes)
    }

    static let endpointPath : PathComponent = "auth"
}
