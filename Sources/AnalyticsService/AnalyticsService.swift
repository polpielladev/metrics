import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol AnalyticsService {
    func send(payload: Payload) async throws
}

class DefaultAnalyticsService: AnalyticsService {
    let endpoint: String
    let transport: Transport
    
    init(endpoint: String, transport: Transport) {
        self.endpoint = endpoint
        self.transport = transport
    }
    
    func send(payload: Payload) async throws {
        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(payload)
        
        _ = try await transport.data(for: request)
    }
}
