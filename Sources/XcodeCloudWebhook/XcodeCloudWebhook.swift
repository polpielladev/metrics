import AWSLambdaRuntime
import AWSLambdaEvents

struct XcodeWebhookBody: Decodable {
    let ciWorkflow: CIWorkflow
    let ciBuildRun: CIBuildRun
    let scmRepository: SCMRepository
    let scmGitReference: SCMGitReference
    
    struct CIWorkflow: Decodable {
        let attributes: Attributes
        
        struct Attributes: Decodable {
            let name: String
        }
    }
    
    struct CIBuildRun: Decodable {
        let id: String
    }
    
    struct SCMRepository: Decodable {
        let attributes: Attributes
        
        struct Attributes: Decodable {
            let repositoryName: String
        }
    }
    
    struct SCMGitReference: Decodable {
        let attributes: Attributes
        
        struct Attributes: Decodable {
            let name: String
        }
    }
}

@main
struct XcodeCloudWebhook: SimpleLambdaHandler {
    func handle(_ request: APIGatewayV2Request, context: LambdaContext) async throws -> APIGatewayV2Response {
        return .init(statusCode: .ok)
    }
}
