import AWSLambdaRuntime
import AWSLambdaEvents
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

enum Provider: String, Codable {
    case xcodeCloud = "xcode-cloud"
    case githubActions = "github-actions"
}

enum CompletionStatus: String, Decodable {
    case succeeded = "SUCCEEDED"
    case failed = "FAILED"
    case errored = "ERRORED"
    case canceled = "CANCELED"
    case skipped = "SKIPPED"
}

struct WebhookPayload: Decodable {
  let ciBuildRun: CIBuildRun
  let ciWorkflow: CIWorkflow
  let scmGitReference: SCMGitReference
  let scmRepository: SCMRepository

  struct CIBuildRun: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let completionStatus: CompletionStatus
      let startedDate: Date?
      let executionProgress: String
      let finishedDate: Date?
      let sourceCommit: SourceCommit

      struct SourceCommit: Decodable {
        let author: Author

        struct Author: Decodable {
          let displayName: String
        }
      }
    }
  }

  struct CIWorkflow: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let name: String
    }
  }

  struct SCMGitReference: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let name: String
      let kind: String
    }
  }

  struct SCMRepository: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let repositoryName: String
    }
  }
}

enum Outcome: String, Encodable {
    case success
    case failure
    case cancelled
}

struct AnalyticsPayload: Encodable {
    let workflow: String
    let duration: Double
    let date: Date
    let provider: Provider
    let author: String
    let outcome: Outcome
    let repository: String
}

struct URLSessionWrapper {
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

@main
struct XcodeCloudWebhook: SimpleLambdaHandler {
    let decoder: JSONDecoder

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        self.decoder = decoder
    }
    
    func handle(_ request: APIGatewayV2Request, context: LambdaContext) async throws -> APIGatewayV2Response {
        guard let body = request.body,
              let bodyData = body.data(using: .utf8),
              let payload = try? decoder.decode(WebhookPayload.self, from: bodyData),
              payload.ciBuildRun.attributes.executionProgress == "COMPLETE" else {
            return .init(statusCode: .badRequest, body: "Could not parse the request content...")
        }

        guard let analyticsEndpoint = ProcessInfo.processInfo.environment["ANALYTICS_ENDPOINT"] else {
            print("ANALYTICS_ENDPOINT is not set. Skipping sending analytics.")
            return .init(statusCode: .internalServerError)
        }
        
        guard let startDate = payload.ciBuildRun.attributes.startedDate,
              let duration = payload
                  .ciBuildRun
                  .attributes
                  .finishedDate?
                  .timeIntervalSince(startDate),
              let outcome = Self.adapt(xcodeCloudOutcome: payload.ciBuildRun.attributes.completionStatus) else {
            return .init(statusCode: .ok, body: "Not handling this request...")
        }
        
        let analyticsPayload = AnalyticsPayload(
            workflow: payload.ciWorkflow.attributes.name,
            duration: duration,
            date: startDate,
            provider: .xcodeCloud,
            author: payload.ciBuildRun.attributes.sourceCommit.author.displayName,
            outcome: outcome,
            repository: payload.scmRepository.attributes.repositoryName
        )
        
        let url = URL(string: analyticsEndpoint)!
        var request = URLRequest(url: url)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(analyticsPayload)
        
        let urlSession = URLSessionWrapper()
        
        _ = try await urlSession.data(for: request)
        return .init(statusCode: .ok)
    }
    
    private static func adapt(xcodeCloudOutcome: CompletionStatus) -> Outcome? {
        switch xcodeCloudOutcome {
        case .succeeded: return .success
        case .failed, .errored: return .failure
        case .canceled: return .cancelled
        // Not logging skipped runs
        case .skipped: return nil
        }
    }
}
