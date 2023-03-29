import Vapor

struct FrontendController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: get)
    }
    
    func get(req: Request) async throws -> View {
        let allMetrics = try await req
            .client
            .get("http://localhost:8080/api/metrics")
        
        print(try
              allMetrics.content.decode([Metric].self))

        return try await req.view.render("Home")
    }
}
