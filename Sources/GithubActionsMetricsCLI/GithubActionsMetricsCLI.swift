import Foundation
import ArgumentParser

struct AnalyticsPayload: Encodable {
    let workflow: String
    let duration: Double
    let date: Date
    let provider: String
    let author: String
    let outcome: String
    let repository: String
}

@main
struct GithubActionsMetricsCLI: AsyncParsableCommand {
    @Argument private var workflow: String
    @Argument private var updatedAt: String
    @Argument private var date: String
    @Argument private var repository: String
    @Argument private var outcome: String
    @Argument private var author: String
    
    func run() async throws {
        guard let updateAtDate = Date(from: updatedAt), let startedAtDate = Date(from: date) else {
            return
        }

        let duration = updateAtDate.timeIntervalSince(startedAtDate)
        
        let payload = AnalyticsPayload(workflow: workflow, duration: duration, date: startedAtDate, provider: "github-actions", author: author, outcome: outcome, repository: repository)
        guard let analyticsEndpoint = ProcessInfo.processInfo.environment["ANALYTICS_ENDPOINT"] else {
            print("ANALYTICS_ENDPOINT is not set. Skipping sending analytics.")
            return
        }

        let url = URL(string: analyticsEndpoint)!
        var request = URLRequest(url: url)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(payload)
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}

extension Date {
    init?(from isoString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: isoString) {
            self = date
        } else {
            return nil
        }
    }
}
