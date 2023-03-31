import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

protocol Transport {
    func data(for request: URLRequest) async throws -> Data
}
