import AWSLambdaRuntime
import AWSLambdaEvents

@main
struct XcodeCloudWebhook: SimpleLambdaHandler {
    func handle(_ request: APIGatewayV2Request, context: LambdaContext) async throws -> APIGatewayV2Response {
        return .init(statusCode: .ok)
    }
}
