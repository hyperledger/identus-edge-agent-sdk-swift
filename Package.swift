// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtalaPRISMSDK",
    platforms: [.iOS(.v15), .watchOS(.v8), .macCatalyst(.v14), .macOS(.v12)],
    products: [
        .library(
            name: "Domain",
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
        .package(path: "OpenAPI/PrismAgentAPI")
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
            dependencies: ["Domain", "Core"],
            path: "Apollo/Sources"
        ),
        .testTarget(
            name: "ApolloTests",
            dependencies: ["Apollo"],
            path: "Apollo/Tests"
        ),
        .target(
            name: "Castor",
            dependencies: ["Domain", "Core", .product(name: "PrismAgentAPI", package: "PrismAgentAPI")],
            path: "Castor/Sources"
        ),
        .testTarget(
            name: "CastorTests",
            dependencies: ["Castor"],
            path: "Castor/Tests"
        ),
        .target(
            name: "Pollux",
            dependencies: ["Domain", "Core", .product(name: "PrismAgentAPI", package: "PrismAgentAPI")],
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
            dependencies: ["Domain", "Core"],
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
