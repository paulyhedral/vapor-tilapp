import Vapor
import Leaf


extension WebsiteController {

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

}

struct AcronymContext : Encodable {
    let title : String
    let acronym : Acronym
    let user : User
    let categories : [Category]
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
