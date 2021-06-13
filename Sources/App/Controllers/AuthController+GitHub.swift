import Vapor
import ImperialGitHub


extension AuthController {

    func addGitHub(routes : RoutesBuilder) throws {
        guard let githubCallbackURL = Environment.get("GITHUB_CALLBACK_URL") else {
            fatalError("GitHub callback URL not set")
        }

        try routes.oAuth(from: GitHub.self,
                authenticate: "auth/login/github",
                callback: githubCallbackURL,
                completion: processGitHubLogin)
//        routes.get(Self.endpointPath, "login", "ios", use: iosGoogleLogin)
    }

    func processGitHubLogin(request : Request, token : String) throws -> EventLoopFuture<ResponseEncodable> {
        return try GitHub.getUser(on: request)
                         .flatMap { userInfo in
                             return User.query(on: request.db)
                                        .filter(\.$username, .equal, userInfo.login)
                                        .first()
                                        .flatMap { foundUser in
                                            guard let existingUser = foundUser else {
                                                let user = User(name: userInfo.name,
                                                        username: userInfo.login,
                                                        password: "github-login")
                                                return user.save(on: request.db)
                                                           .flatMap {
                                                               request.session.authenticate(user)
                                                               return generateRedirect(on: request, for: user)
                                                           }
                                            }

                                            request.session.authenticate(existingUser)
                                            return generateRedirect(on: request, for: existingUser)
                                        }
                         }
    }

//    func iosGoogleLogin(_ req : Request) -> Response {
//        req.session.data[Constants.oauthLoginDataKey] = Constants.iosLoginType
//        return req.redirect(to: "/auth/login/google")
//    }

}

struct GitHubUserInfo : Content {
    let name : String
    let login : String
}

extension GitHub {

    static func getUser(on request : Request) throws -> EventLoopFuture<GitHubUserInfo> {
        var headers = HTTPHeaders()
        try headers.add(name: .authorization, value: "token \(request.accessToken())")
        headers.add(name: .userAgent, value: "vapor")

        let githubUserAPIURL : URI = "https://api.github.com/user"
        return request
                .client
                .get(githubUserAPIURL, headers: headers)
                .flatMapThrowing { response in
                    guard response.status == .ok else {
                        if response.status == .unauthorized {
                            throw Abort.redirect(to: "/auth/login/github")
                        }
                        else {
                            throw Abort(.internalServerError)
                        }
                    }

                    return try response.content
                            .decode(GitHubUserInfo.self)
                }
    }
}
