import Fluent

struct CreateMetric: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("metrics")
            .id()
            .field("workflow", .string, .required)
            .field("duration", .double, .required)
            .field("date", .date, .required)
            .field("provider", .string, .required)
            .field("outcome", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("metrics").delete()
    }
}
