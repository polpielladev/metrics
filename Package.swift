// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Metrics",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .executable(name: "XcodeCloudWebhook", targets: ["XcodeCloudWebhook"]),
        .executable(name: "GithubActionsMetricsCLI", targets: ["GithubActionsMetricsCLI"]),
        .library(name: "AnalyticsService", targets: ["AnalyticsService"])
    ],
    dependencies: [
        // 💧 Vapor
        .package(url: "https://github.com/vapor/vapor.git", exact: "4.74.2"),
        .package(url: "https://github.com/vapor/fluent.git", exact: "4.7.1"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", exact: "2.5.1"),
        // ⚡️ AWS Lambda
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", exact: "1.0.0-alpha.1"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", exact: "0.1.0"),
        // 🍁 Leaf
        .package(url: "https://github.com/vapor/leaf.git", exact: "4.2.4"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.2.2")
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
        .executableTarget(
            name: "GithubActionsMetricsCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        // ⚡️ AWS Lambda
        .executableTarget(
            name: "XcodeCloudWebhook",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events")
            ]
        ),
        .target(name: "AnalyticsService")
    ]
)
