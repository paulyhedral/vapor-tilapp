import Vapor
import Leaf


extension WebsiteController {

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

}

struct IndexContext : Encodable {
    let title : String
    let acronyms : [Acronym]
    let userLoggedIn : Bool
    let showCookieMessage : Bool
}
