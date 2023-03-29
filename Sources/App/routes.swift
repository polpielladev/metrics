import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: MetricsController())
    try app.register(collection: FrontendController())
}
