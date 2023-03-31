//
//  File.swift
//  
//
//  Created by Pol Piella Abadia on 31/03/2023.
//

import Foundation

public enum Factory {
    public static func make(with endpoint: String) -> AnalyticsService {
        let multiPlatformTransport = URLSessionWrapper()
        
        return DefaultAnalyticsService(endpoint: endpoint, transport: multiPlatformTransport)
    }
}
