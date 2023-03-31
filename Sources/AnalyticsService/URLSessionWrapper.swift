//
//  File.swift
//  
//
//  Created by Pol Piella Abadia on 31/03/2023.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct URLSessionWrapper: Transport {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func data(for request: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            session.dataTask(with: request) { data, _, error in
                if let data {
                    continuation.resume(returning: data)
                } else {
                    // TODO: - Proper error handling...
                    if let error {
                        continuation.resume(throwing: error)
                    }
                }
            }
            .resume()
        }
    }
}
