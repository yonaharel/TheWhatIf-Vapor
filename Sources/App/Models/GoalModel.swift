//
//  Goal.swift
//  
//
//  Created by Yona Harel on 23/07/2022.
//

import Vapor
import Shared
import Fluent

extension Goal: Content {}


final class GoalModel: Model, Content {
    static let schema = "goals"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "date")
    var date: Date
    
    @Field(key: "goal")
    var goal: Int
    
    @Field(key: "progress")
    var progress: Int
    
    init() { }
    
    init(id: UUID? = nil,
         title: String,
         type: String,
         date: Date,
         goal: Int,
         progress: Int) {
        self.id = id
        self.title = title
        self.type = type
        self.date = date
        self.goal = goal
        self.progress = progress
    }
}

extension Goal {
    init(model: GoalModel) throws {
        guard let type: GoalType = .init(rawValue: model.type) else {
            throw Abort(.badRequest)
        }
        try self.init(
            id: model.requireID(),
            title: model.title,
            type: type,
            dueDate: model.date,
            progress: model.progress,
            target: model.goal
        )
    }
    
    func makeGoalModel() -> GoalModel {
        .init(id: self.id,
              title: self.title,
              type: self.type.rawValue,
              date: self.dueDate,
              goal: self.target,
              progress: self.progress
        )
    }
}
