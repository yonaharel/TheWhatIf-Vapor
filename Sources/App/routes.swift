import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, The What If, By Yona!"
    }

    try app.register(collection: TodoController())
    try app.register(collection: GoalController())
}
