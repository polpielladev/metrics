import Vapor

struct HomeContext: Encodable {
    let metrics: [Metric]
}

struct FrontendController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: get)
    }
    
    func get(req: Request) async throws -> View {
        let allMetrics = try await Metric.query(on: req.db)
            .sort(\.$date, .descending)
            .all()

        return try await req.view.render("Home", HomeContext(metrics: allMetrics))
    }
}
