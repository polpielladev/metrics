import Fluent

struct CreateMetric: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("metrics")
            .id()
            .field("workflow", .string, .required)
            .field("duration", .double, .required)
            .field("date", .datetime, .required)
            .field("provider", .string, .required)
            .field("outcome", .string, .required)
            .field("repository", .string, .required)
            .field("author", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("metrics").delete()
    }
}
