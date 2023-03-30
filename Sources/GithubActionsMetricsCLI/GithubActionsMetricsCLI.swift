import Foundation
import ArgumentParser

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
    
        print(workflow)
        print(duration)
        print(repository)
        print(outcome)
        print(author)
    }
}

extension Date {
    init?(from isoString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: isoString) {
            self = date
        } else {
            return nil
        }
    }
}
