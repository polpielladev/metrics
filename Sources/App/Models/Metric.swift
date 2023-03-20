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
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "workflow")
    var workflow: String
    
    @Field(key: "duration")
    var duration: TimeInterval
    
    @Field(key: "date")
    var date: Date
    
    @Enum(key: "provider")
    var provider: Provider
    
    @Enum(key: "outcome")
    var outcome: Outcome
    
    init() {}
    
    init(id: UUID? = nil, workflow: String, duration: TimeInterval, provider: Provider, outcome: Outcome) {
        self.id = id
        self.workflow = workflow
        self.duration = duration
        self.provider = provider
        self.outcome = outcome
    }
}
