import Compute

let router = Router()

struct WorkflowWebhookData: Codable {
    let action: String
    let workflowRun: WorkflowRun
    
    struct WorkflowRun: Codable {
        let createdAt: String
        let updatedAt: String
        let headBranch: String?
        let name: String
        let url: URL
        let workflowUrl: URL
    }
}

struct MetricsDataPoint: Encodable {
    let workflow: String
    let duration: TimeInterval
    let date: Date
    let provider: String
}

extension JSONDecoder {
    static let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension JSONEncoder {
    static let snakeCaseEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
}

router.post("/") { request, response in
    let webhookData: WorkflowWebhookData = try await request.body.decode(decoder: .snakeCaseDecoder)
    let dataPoint = MetricsDataPoint(workflow: webhookData.workflowRun.name, duration: 0.2, date: Date(), provider: "github-actions")
    let request = FetchRequest(URL(string: "http://localhost")!, .options(method: .post, body: try .json(dataPoint)))
    let ghResponse = try await fetch(request)
    if ghResponse.ok {
        try await response.status(200).write("Done!")
    } else {
        try await response.status(ghResponse.status).write("Something went wrong...")
    }
}

try await router.listen()
