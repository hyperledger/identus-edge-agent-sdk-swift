// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "e2e",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", .upToNextMinor(from: "1.2.1")),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "1.3.2")),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "1.0.1")),
        .package(url: "https://github.com/nschum/SwiftHamcrest", .upToNextMajor(from: "2.2.1")),
        .package(path: "../")
    ],
    targets: [
        .testTarget(
            name: "e2e",
            dependencies: [
                .product(name: "EdgeAgent", package: "atala-prism-wallet-sdk-swift"),
                .product(name: "Domain", package: "atala-prism-wallet-sdk-swift"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "SwiftHamcrest", package: "SwiftHamcrest")
            ],
            path: "e2eTests",
            resources: [
                .copy("Resources")
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                )
            ]
        )
    ]
)
