//
// WebsiteController+Auth.swift
// Copyright (c) 2021 Paul Schifferer.
//

//import ImperialAuth0
import Leaf
import Vapor
import SendGrid


//extension WebsiteController {
//
//    func forgottenPasswordHandler(_ req : Request) throws -> EventLoopFuture<View> {
//        req.view.render("forgottenPassword", [ "title" : "Reset your password" ])
//    }
//
//    func forgottenPasswordPostHandler(_ req : Request) throws -> EventLoopFuture<View> {
//        let email = try req.content.get(String.self, at: "email")
//        return User.query(on: req.db)
//                   .filter(\.$email, .equal, email)
//                   .first()
//                   .flatMap { user in
//                       guard let user = user else {
//                           return req.view.render("forgottenPasswordConfirmed", [ "title" : "Password Reset Email Sent" ])
//                       }
//
//                       let resetTokenString = Data([ UInt8 ].random(count: 32)).base32EncodedString()
//                       let resetToken : ResetPasswordToken
//                       do {
//                           resetToken = try ResetPasswordToken(token: resetTokenString, userId: try user.requireID())
//                       }
//                       catch {
//                           return req.eventLoop.future(error: error)
//                       }
//
//                       return resetToken.save(on: req.db)
//                                        .flatMap {
//                                            let emailContent = """
//                                                               <p>You've requested to reset your password.
//                                                               <a href="http://localhost:8080/resetPassword?token=\(resetTokenString)">Click here</a>
//                                                               to reset your password.</p>
//                                                               """
//                                            let emailAddress = EmailAddress(email: user.email, name: user.name)
//                                            let fromEmail = EmailAddress(email: "admin@sweetrpg.com", name: "TILApp")
//                                            let emailConfig = Personalization(to: [ emailAddress ],
//                                                    subject: "Reset Your Password")
//                                            let email = SendGridEmail(personalizations: [ emailConfig ],
//                                                    from: fromEmail,
//                                                    content: [
//                                                        [ "type" : "text/html",
//                                                          "value" : emailContent ]
//                                                    ])
//                                            let emailSend : EventLoopFuture<Void>
//                                            do {
//                                                emailSend = try req.application
//                                                        .sendgrid
//                                                        .client
//                                                        .send(email: email, on: req.eventLoop)
//                                            }
//                                            catch {
//                                                return req.eventLoop.future(error: error)
//                                            }
//
//                                            return emailSend.flatMap {
//                                                req.view.render("forgottenPasswordConfirmed", [ "title" : "Password Reset Email Sent" ])
//                                            }
//                                        }
//                   }
//    }
//
//    func resetPasswordHandler(_ req : Request) throws -> EventLoopFuture<View> {
//        guard let token = try? req.query.get(String.self, at: "token") else {
//            let context = ResetPasswordContext(error: true)
//            return req.view.render("resetPassword", context)
//        }
//
//        return ResetPasswordToken.query(on: req.db)
//                                 .filter(\.$token, .equal, token)
//                                 .first()
//                                 .unwrap(or: Abort.redirect(to: "/"))
//                                 .flatMap { token in
//                                     token.$user.get(on: req.db)
//                                                .flatMap { user in
//                                                    do {
//                                                        try req.session.set("ResetPasswordUser", to: user)
//                                                    }
//                                                    catch {
//                                                        return req.eventLoop.future(error: error)
//                                                    }
//
//                                                    return token.delete(on: req.db)
//                                                }
//                                                .flatMap {
//                                                    req.view.render("resetPassword", ResetPasswordContext())
//                                                }
//                                 }
//    }
//}
//
//struct ResetPasswordContext : Encodable {
//    let title = "Reset Password"
//    let error : Bool?
//
//    init(error : Bool? = nil) {
//        self.error = error
//    }
//}
