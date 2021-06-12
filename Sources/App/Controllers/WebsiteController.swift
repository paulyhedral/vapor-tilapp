import Vapor
import Leaf


struct WebsiteController : RouteCollection {

    func boot(routes : RoutesBuilder) throws {

        let authSessionRoutes = routes.grouped(User.sessionAuthenticator())
        authSessionRoutes.get("login", use: loginHandler)

        let credentialsAuthRoutes = authSessionRoutes.grouped(User.credentialsAuthenticator())
        credentialsAuthRoutes.post("login", use: loginPostHandler)

        authSessionRoutes.post("logout", use: logoutHandler)
        authSessionRoutes.get("register", use: registerHandler)
        authSessionRoutes.post("register", use: registerPostHandler)
        authSessionRoutes.get(use: indexHandler)
        authSessionRoutes.get("acronyms", ":acronymId", use: acronymHandler)
        authSessionRoutes.get("users", ":userId", use: userHandler)
        authSessionRoutes.get("users", use: allUsersHandler)
        authSessionRoutes.get("categories", use: allCategoriesHandler)
        authSessionRoutes.get("categories", ":categoryId", use: categoryHandler)

        let protectedRoutes = authSessionRoutes.grouped(User.redirectMiddleware(path: "/login"))
        protectedRoutes.get("acronyms", "create", use: createAcronymHandler)
        protectedRoutes.post("acronyms", "create", use: createAcronymPostHandler)
        protectedRoutes.get("acronyms", ":acronymId", "edit", use: editAcronymHandler)
        protectedRoutes.post("acronyms", ":acronymId", "edit", use: editAcronymPostHandler)
        protectedRoutes.post("acronyms", ":acronymId", "delete", use: deleteAcronymHandler)
    }
}
