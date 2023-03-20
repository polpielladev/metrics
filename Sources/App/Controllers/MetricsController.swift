import Fluent
import Vapor

struct MetricsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api", "metrics")
        api.get(use: get)
        api.get(":id", use: find)
        api.post(use: create)
        api.delete(":id", use: delete)
    }
    
    func get(req: Request) async throws -> [Metric] {
        try await Metric.query(on: req.db)
            .sort(\.$date, .descending)
            .all()
    }
    
    func find(req: Request) async throws -> Metric {
        if let metric = try await Metric.find(req.parameters.get("id"), on: req.db) {
            return metric
        } else {
            throw Abort(.badRequest)
        }
    }

    func create(req: Request) async throws -> Metric {
        let metric = try req.content.decode(Metric.self)
        try await metric.save(on: req.db)
        return metric
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let metric = try await Metric.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await metric.delete(on: req.db)
        return .noContent
    }
}
