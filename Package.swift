// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtalaPRISMSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AtalaDomain",
            targets: ["Domain"]
        ),
        .library(
            name: "Apollo",
            targets: ["Apollo"]
        ),
        .library(
            name: "Castor",
            targets: ["Castor"]
        ),
        .library(
            name: "Pollux",
            targets: ["Pollux"]
        ),
        .library(
            name: "Mercury",
            targets: ["Mercury"]
        ),
        .library(
            name: "Pluto",
            targets: ["Pluto"]
        ),
        .library(
            name: "Builders",
            targets: ["Builders"]
        ),
        .library(
            name: "Experiences",
            targets: ["Experiences"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.4"
        ),
        .package(url: "https://github.com/MarcoEidinger/SwiftFormatPlugin", from: "0.50.3"),
        .package(url: "https://github.com/realm/SwiftLint.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.7.0"),
        .package(url: "https://github.com/antlr/antlr4", branch: "master"),
        .package(name: "PrismAPI", path: "PrismAPISDK")
    ],
    targets: [
        .target(
            name: "Domain",
            path: "Domain/Sources"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            path: "Domain/Tests"
        ),
        .target(
            name: "Apollo",
            dependencies: ["Domain", "Core", "PrismAPI"],
            path: "Apollo/Sources",
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "ApolloTests",
            dependencies: ["Apollo"],
            path: "Apollo/Tests"
        ),
        .target(
            name: "Castor",
            dependencies: [
                "Domain",
                "Core",
                "PrismAPI",
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Antlr4", package: "antlr4")
            ],
            path: "Castor/Sources"
        ),
        .testTarget(
            name: "CastorTests",
            dependencies: ["Castor", "Apollo"],
            path: "Castor/Tests"
        ),
        .target(
            name: "Pollux",
            dependencies: [
                "Domain",
                "Core"
            ],
            path: "Pollux/Sources"
        ),
        .testTarget(
            name: "PolluxTests",
            dependencies: ["Pollux"],
            path: "Pollux/Tests"
        ),
        .target(
            name: "Mercury",
            dependencies: ["Domain", "Core"],
            path: "Mercury/Sources"
        ),
        .testTarget(
            name: "MercuryTests",
            dependencies: ["Mercury"],
            path: "Mercury/Tests"
        ),
        .target(
            name: "Pluto",
            dependencies: ["Domain"],
            path: "Pluto/Sources"
        ),
        .testTarget(
            name: "PlutoTests",
            dependencies: ["Pluto"],
            path: "Pluto/Tests"
        ),
        .target(
            name: "Builders",
            dependencies: ["Domain", "Castor", "Pollux", "Mercury", "Pluto", "Apollo"],
            path: "Builders/Sources"
        ),
        .target(
            name: "Experiences",
            dependencies: ["Domain", "Builders", "Core"],
            path: "Experiences/Sources"
        ),
        .testTarget(
            name: "ExperiencesTests",
            dependencies: ["Experiences"],
            path: "Experiences/Tests"
        ),
        // Internal core components (ex: logging) not public distributed
        .target(
            name: "Core",
            dependencies: [
                "Domain",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Core/Sources"
        )
    ]
)
