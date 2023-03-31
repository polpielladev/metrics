import AWSLambdaRuntime
import AWSLambdaEvents
import AnalyticsService
import Foundation

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
            return .init(statusCode: .ok, body: "Not handling the request...")
        }

        guard let analyticsEndpoint = ProcessInfo.processInfo.environment["ANALYTICS_ENDPOINT"] else {
            print("ANALYTICS_ENDPOINT is not set. Skipping sending analytics.")
            return .init(statusCode: .internalServerError)
        }
        
        let analyticsService = Factory.make(with: analyticsEndpoint)
        
        guard let startDate = payload.ciBuildRun.attributes.startedDate,
              let duration = payload
                  .ciBuildRun
                  .attributes
                  .finishedDate?
                  .timeIntervalSince(startDate),
              let outcome = Self.adapt(xcodeCloudOutcome: payload.ciBuildRun.attributes.completionStatus) else {
            return .init(statusCode: .ok, body: "Not handling this request...")
        }
        
        let analyticsPayload = Payload(
            workflow: payload.ciWorkflow.attributes.name,
            duration: Int(duration),
            date: startDate,
            provider: .xcodeCloud,
            author: payload.ciBuildRun.attributes.sourceCommit.author.displayName,
            outcome: outcome,
            repository: payload.scmRepository.attributes.repositoryName
        )
        _ = try await analyticsService.send(payload: analyticsPayload)
        
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
