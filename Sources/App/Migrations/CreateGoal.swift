//
//  CreateGoal.swift
//  
//
//  Created by Yona Harel on 23/07/2022.
//
import Fluent

struct CreateGoal: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("goals")
            .id()
            .field("title", .string, .required)
            .field("type", .string, .required)
            .field("date", .date, .required)
            .field("goal", .int, .required)
            .field("progress", .int)
            .create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("goals").delete()
    }
}
