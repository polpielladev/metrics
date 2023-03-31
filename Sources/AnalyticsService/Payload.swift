import Foundation

public enum Provider: String, Codable {
    case xcodeCloud = "xcode-cloud"
    case githubActions = "github-actions"
}

public enum Outcome: String, Encodable {
    case success
    case failure
    case cancelled
}

public struct Payload: Encodable {
    let workflow: String
    let duration: Double
    let date: Date
    let provider: Provider
    let author: String
    let outcome: Outcome
    let repository: String
}
