//
// HealthController.swift
// Copyright (c) 2021 Paul Schifferer.
//

import Vapor

// MARK: - HealthController

struct HealthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let healthRoutes = routes.grouped("health")
        healthRoutes.get("status", use: self.healthCheckHandler)
        healthRoutes.get("ping", use: self.pingHandler)
    }

    func healthCheckHandler(_ req: Request) throws -> EventLoopFuture<HealthInfo> {
        User.query(on: req.db)
            .count()
            .map { userCount in
                let info = HealthInfo(timestamp: Date(),
                                      dbHealthy: userCount > 1)
                return info
            }
    }

    func pingHandler(_ req: Request) throws -> EventLoopFuture<Pong> {
        let pong = Pong(timestamp: Date())
        return req.eventLoop.future(pong)
    }
}

// MARK: - HealthInfo

struct HealthInfo: Content {
    let timestamp: Date
    let dbHealthy: Bool
}

// MARK: - Pong

struct Pong: Content {
    let timestamp: Date
}
