// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Metrics",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        // 💨 Fastly
        .package(url: "https://github.com/swift-cloud/Compute", from: "2.8.0")
    ],
    targets: [
        // 💧 Vapor
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor")
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
        // 💨 Fastly
        .executableTarget(name: "GithubActionsWebhook", dependencies: ["Compute"])
    ]
)
