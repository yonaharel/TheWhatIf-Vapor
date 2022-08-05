//
// GoalController.swift
//  
//
//  Created by Yona Harel on 23/07/2022.
//

import Vapor
import Shared
import Fluent
import FluentSQLiteDriver

struct GoalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let goalRoutes = routes.grouped("goals")
        goalRoutes.post("create", use: create)
        goalRoutes.post("update", use: update)
        goalRoutes.delete(use: delete)
        goalRoutes.get("all", use: getAll)
        goalRoutes.group(":goalId") { goal in
            goal.delete(use: delete)
        }
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let goal = try await GoalModel.find(req.parameters.get("goalId"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await goal.delete(on: req.db)
        print("DELETED GOAL \(goal.id!)")
        return .ok
    }
    
    func create(req: Request) async throws -> Goal {
        let body = try req.content.decode(Goal.self)
        let create = body.makeGoalModel()
        try await create.save(on: req.db)
        let model = try await GoalModel.getSingleByID(create.id, on: req.db)
        return try Goal(model: model)
    }
    

    func update(req: Request) async throws -> Goal {
        let updated = try req.content.decode(Goal.self)
        guard let goalModel = try await GoalModel.find(updated.id, on: req.db) else {
            throw Abort(.custom(code: 404, reasonPhrase: "The goal you're trying to update doesn't exist."))
        }
        goalModel.updateData(from: updated)
        try await goalModel.save(on: req.db)
        return try await Goal(model: GoalModel.getSingleByID(updated.id, on: req.db))
    }
    
    func getAll(req: Request) async throws -> [Goal] {
        try await GoalModel.query(on: req.db).all().map(Goal.init)
    }
    
}

// MARK: - Notification Manager
class RemoteNotificationManager {
    let shared = RemoteNotificationManager()
    private init() {}
    func registerNotification(for Goal: GoalModel) throws {
        throw Abort(.notImplemented)
    }
}


extension GoalModel {
    static func getSingleByID(_ id: GoalModel.IDValue?, on database: Database) async throws -> GoalModel {
        guard let id = id else {
            throw Abort(.custom(code: 500, reasonPhrase: "no id"))
        }
        guard let model = try await GoalModel.find(id, on: database) else {
            throw Abort(.notFound)
        }
        return model
    }
    
}

extension GoalModel {
    func updateData(from goal: Goal) {
        self.goal = goal.target
        self.progress = goal.progress
        self.type = goal.type.rawValue
        self.date = goal.dueDate
        self.title = goal.title
    }
}
