import Foundation
import ArgumentParser
import AnalyticsService

enum GithubActionOutcome: String, ExpressibleByArgument {
    case success
    case failure
    case neutral
    case cancelled
    case timed_out
    case action_required
    case stale
    case null
    case skipped
}

@main
struct GithubActionsMetricsCLI: AsyncParsableCommand {
    @Argument private var workflow: String
    @Argument private var updatedAt: String
    @Argument private var date: String
    @Argument private var repository: String
    @Argument private var outcome: GithubActionOutcome
    @Argument private var author: String
    
    func run() async throws {
        guard let updateAtDate = Date(from: updatedAt), let startedAtDate = Date(from: date) else {
            return
        }
        
        let duration = updateAtDate.timeIntervalSince(startedAtDate)
        
        guard let outcome = adapt(githubActionsOutcome: outcome) else {
            print("Not hadling the GHA outcome \(outcome.rawValue)")
            return
        }
        
        let payload = Payload(
            workflow: workflow,
            duration: duration,
            date: startedAtDate,
            provider: .githubActions,
            author: author,
            outcome: outcome,
            repository: repository
        )
        guard let analyticsEndpoint = ProcessInfo.processInfo.environment["ANALYTICS_ENDPOINT"] else {
            print("ANALYTICS_ENDPOINT is not set. Skipping sending analytics.")
            return
        }
        let analyticsService = Factory.make(with: analyticsEndpoint)
        _ = try await analyticsService.send(payload: payload)
    }
    
    private func adapt(githubActionsOutcome: GithubActionOutcome) -> Outcome? {
        switch githubActionsOutcome {
        case .success: return .success
        case .failure: return .failure
        case .cancelled: return .cancelled
        default: return nil
        }
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
