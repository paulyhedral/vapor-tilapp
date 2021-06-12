import Vapor
import Leaf


struct WebsiteController : RouteCollection {

    func boot(routes : RoutesBuilder) throws {

        let authSessionRoutes = routes.grouped(User.sessionAuthenticator())
        authSessionRoutes.get("login", use: loginHandler)

        let credentialsAuthRoutes = authSessionRoutes.grouped(User.credentialsAuthenticator())
        credentialsAuthRoutes.post("login", use: loginPostHandler)

        authSessionRoutes.post("logout", use: logoutHandler)
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

    func indexHandler(_ req : Request) -> EventLoopFuture<View> {
        Acronym.query(on: req.db)
               .all()
               .flatMap { acronyms in
                   let userLoggedIn = req.auth.has(User.self)
                   let showCookieMessage = req.cookies["cookies-accepted"] == nil
                   let context = IndexContext(title: "Home Page",
                           acronyms: acronyms,
                           userLoggedIn: userLoggedIn,
                           showCookieMessage: showCookieMessage)
                   return req.view.render("index", context)
               }
    }

    func acronymHandler(_ req : Request) -> EventLoopFuture<View> {
        Acronym.find(req.parameters.get("acronymId"),
                       on: req.db)
               .unwrap(or: Abort(.notFound))
               .flatMap { acronym in
                   let userFuture = acronym.$user.get(on: req.db)
                   let categoriesFuture = acronym.$categories.query(on: req.db).all()
                   return userFuture.and(categoriesFuture)
                                    .flatMap { user, categories in
                                        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user, categories: categories)
                                        return req.view.render("acronym", context)
                                    }
               }
    }

    func userHandler(_ req : Request) -> EventLoopFuture<View> {

        User.find(req.parameters.get("userId"),
                    on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
                              .flatMap { acronyms in
                                  let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                                  return req.view.render("user", context)
                              }
            }
    }

    func allUsersHandler(_ req : Request) -> EventLoopFuture<View> {
        User.query(on: req.db)
            .all()
            .flatMap { users in
                let context = AllUsersContext(title: "All Users", users: users)
                return req.view.render("allUsers", context)
            }
    }

    func allCategoriesHandler(_ req : Request) -> EventLoopFuture<View> {
        Category.query(on: req.db)
                .all()
                .flatMap { categories in
                    let context = AllCategoriesContext(categories: categories)
                    return req.view.render("allCategories", context)
                }
    }

    func categoryHandler(_ req : Request) -> EventLoopFuture<View> {
        Category.find(req.parameters.get("categoryId"),
                        on: req.db)
                .unwrap(or: Abort(.notFound))
                .flatMap { category in
                    category.$acronyms.get(on: req.db)
                                      .flatMap { acronyms in
                                          let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
                                          return req.view.render("category", context)
                                      }
                }
    }

    func createAcronymHandler(_ req : Request) -> EventLoopFuture<View> {
        let token = [UInt8].random(count: 16).base64
        let context = CreateAcronymContext(csrfToken: token)
        req.session.data["CSRF_TOKEN"] = token
        return req.view.render("createAcronym", context)
    }

    func createAcronymPostHandler(_ req : Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateAcronymFormData.self)
        let user = try req.auth.require(User.self)
        let expectedToken = req.session.data["CSRF_TOKEN"]
        req.session.data["CSRF_TOKEN"] = nil
        guard let csrfToken = data.csrfToken, expectedToken == csrfToken else {
            throw Abort(.badRequest)
        }

        let acronym = Acronym(short: data.short, long: data.long, userId: try user.requireID())
        return acronym.save(on: req.db)
                      .flatMap {
                          guard let id = acronym.id else {
                              return req.eventLoop.future(error: Abort(.internalServerError))
                          }

                          let categorySaves : [EventLoopFuture<Void>] = (data.categories ?? [])
                                  .map { name in
                              Category.addCategory(name, to: acronym, on: req)
                          }

                          let redirect = req.redirect(to: "/acronyms/\(id)")
                          return categorySaves.flatten(on: req.eventLoop)
                                              .transform(to: redirect)
                      }
    }

    func editAcronymHandler(_ req : Request) -> EventLoopFuture<View> {
        return Acronym.find(req.parameters.get("acronymId"),
                              on: req.db)
                      .unwrap(or: Abort(.notFound))
                      .flatMap { acronym in
                          acronym.$categories.get(on: req.db)
                                             .flatMap { categories in
                                                 let context = EditAcronymContext(acronym: acronym, categories: categories)
                                                 return req.view.render("createAcronym", context)
                                             }
                      }
    }

    func editAcronymPostHandler(_ req : Request) throws -> EventLoopFuture<Response> {
        let updateData = try req.content.decode(CreateAcronymFormData.self)
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        return Acronym.find(req.parameters.get("acronymId"),
                              on: req.db)
                      .unwrap(or: Abort(.notFound))
                      .flatMap { acronym in
                          acronym.short = updateData.short
                          acronym.long = updateData.long
                          acronym.$user.id = userId

                          guard let id = acronym.id else {
                              return req.eventLoop.future(error: Abort(.internalServerError))
                          }

                          return acronym.save(on: req.db)
                                        .flatMap {
                                            acronym.$categories.get(on: req.db)
                                        }
                                        .flatMap { existingCategories in
                                            let existingStringArray = existingCategories.map {
                                                $0.name
                                            }
                                            let existingSet = Set<String>(existingStringArray)
                                            let newSet = Set<String>(updateData.categories ?? [])
                                            let categoriesToAdd = newSet.subtracting(existingSet)
                                            let categoriesToRemove = existingSet.subtracting(newSet)

                                            var categoryResults : [EventLoopFuture<Void>] = categoriesToAdd.map {
                                                Category.addCategory($0, to: acronym, on: req)
                                            }

                                            for categoryNameToRemove in categoriesToRemove {
                                                if let category = existingCategories.first(where: { $0.name == categoryNameToRemove }) {
                                                    categoryResults.append(acronym.$categories.detach(category, on: req.db))
                                                }
                                            }

                                            let redirect = req.redirect(to: "/acronyms/\(id)")
                                            return categoryResults.flatten(on: req.eventLoop)
                                                                  .transform(to: redirect)
                                        }
                      }
    }

    func deleteAcronymHandler(_ req : Request) throws -> EventLoopFuture<Response> {
        Acronym.find(req.parameters.get("acronymId"),
                       on: req.db)
               .unwrap(or: Abort(.notFound))
               .flatMap { acronym in
                   acronym.delete(on: req.db)
                          .transform(to: req.redirect(to: "/"))
               }
    }

    // MARK: - Login

    func loginHandler(_ req : Request) throws -> EventLoopFuture<View> {
        let context : LoginContext

        if let error = req.query[Bool.self, at: "error"], error {
            context = LoginContext(loginError: true)
        }
        else {
            context = LoginContext()
        }

        return req.view.render("login", context)
    }

    func loginPostHandler(_ req : Request) throws -> EventLoopFuture<Response> {
        if req.auth.has(User.self) {
            return req.eventLoop.future(req.redirect(to: "/"))
        }
        else {
            let context = LoginContext(loginError: true)
            return req.view
                    .render("login", context)
                    .encodeResponse(for: req)
        }
    }

    func logoutHandler(_ req : Request) throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
}

struct IndexContext : Encodable {
    let title : String
    let acronyms : [Acronym]
    let userLoggedIn : Bool
    let showCookieMessage : Bool
}

struct AcronymContext : Encodable {
    let title : String
    let acronym : Acronym
    let user : User
    let categories : [Category]
}

struct UserContext : Encodable {
    let title : String
    let user : User
    let acronyms : [Acronym]
}

struct AllUsersContext : Encodable {
    let title : String
    let users : [User]
}

struct AllCategoriesContext : Encodable {
    let title = "All Categories"
    let categories : [Category]
}

struct CategoryContext : Encodable {
    let title : String
    let category : Category
    let acronyms : [Acronym]
}

struct CreateAcronymContext : Encodable {
    let title = "Create an Acronym"
    let csrfToken : String
}

struct EditAcronymContext : Encodable {
    let title = "Edit Acronym"
    let acronym : Acronym
    let editing = true
    let categories : [Category]
}

struct CreateAcronymFormData : Content {
    let short : String
    let long : String
    let categories : [String]?
    let csrfToken : String?
}

struct LoginContext : Encodable {
    let title = "Log In"
    let loginError : Bool

    init(loginError : Bool = false) {
        self.loginError = loginError
    }
}
