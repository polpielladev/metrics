// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Metrics",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .executable(name: "XcodeCloudWebhook", targets: ["XcodeCloudWebhook"]),
        .executable(name: "GithubActionsWebhook", targets: ["GithubActionsWebhook"])
    ],
    dependencies: [
        // 💧 Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        // 💨 Fastly Compute @ Edge
        .package(url: "https://github.com/swift-cloud/Compute", from: "2.8.0"),
        // ⚡️ AWS Lambda
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", exact: "1.0.0-alpha.1"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", exact: "0.1.0"),
        // 🍁 Leaf
        .package(url: "https://github.com/vapor/leaf.git", exact: "4.2.4")
    ],
    targets: [
        // 💧 Vapor
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf")
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
        // 💨 Fastly Compute @ Edge
        .executableTarget(name: "GithubActionsWebhook", dependencies: ["Compute"]),
        // ⚡️ AWS Lambda
        .executableTarget(
            name: "XcodeCloudWebhook",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events")
            ]
        )
    ]
)
