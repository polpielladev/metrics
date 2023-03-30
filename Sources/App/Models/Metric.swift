import Vapor
import Fluent

enum Provider: String, Codable {
    case xcodeCloud = "xcode-cloud"
    case githubActions = "github-actions"
}

enum Outcome: String, Codable {
    case success
    case failure
    case cancelled
}

final class Metric: Model, Content {
    static let schema = "metrics"
    @ID(key: .id) var id: UUID?
    @Field(key: "workflow") var workflow: String
    @Field(key: "duration") var duration: TimeInterval
    @Field(key: "date") var date: Date
    @Field(key: "repository") var repository: String
    @Field(key: "author") var author: String
    @Enum(key: "provider") var provider: Provider
    @Enum(key: "outcome") var outcome: Outcome
    
    init() {}
}
