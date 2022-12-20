// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtalaPRISMSDK",
    platforms: [.iOS(.v15)],
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
            name: "PrismAgent",
            targets: ["PrismAgent"]
        ),
        .library(
            name: "Authenticate",
            targets: ["Authenticate"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.4"
        ),
        // This doesnt seem to be working properly on command line, removing for now
//        .package(url: "https://github.com/realm/SwiftLint.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.7.0"),
        .package(url: "https://github.com/antlr/antlr4", branch: "master"),
        .package(url: "https://github.com/input-output-hk/atala-prism-didcomm-swift", from: "0.3.4"),
        .package(url: "https://github.com/input-output-hk/atala-prism-crypto-sdk-sp", from: "1.4.1"),
        .package(url: "https://github.com/swift-libp2p/swift-multibase", branch: "main"),
        .package(url:"https://github.com/IBM-Swift/Swift-JWT", from: "4.0.0")
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
            dependencies: [
                "Domain",
                "Core",
                .product(name: "PrismAPI", package: "atala-prism-crypto-sdk-sp"),
                .product(name: "SwiftJWT", package: "Swift-JWT")
            ],
            path: "Apollo/Sources"
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
                .product(name: "Multibase", package: "swift-multibase"),
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
            dependencies: [
                "Domain",
                "Core",
                .product(name: "DIDCommxSwift", package: "atala-prism-didcomm-swift")
            ],
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
            path: "Pluto/Sources",
            resources: [.process("Resources/PrismPluto.xcdatamodeld")]
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
            name: "PrismAgent",
            dependencies: ["Domain", "Builders", "Core"],
            path: "PrismAgent/Sources"
        ),
        .testTarget(
            name: "PrismAgentTests",
            dependencies: ["PrismAgent"],
            path: "PrismAgent/Tests"
        ),
        .target(
            name: "Authenticate",
            dependencies: ["Domain", "Builders", "Core"],
            path: "Authenticate/Sources"
        ),
        .testTarget(
            name: "AuthenticateTests",
            dependencies: ["Authenticate"],
            path: "Authenticate/Tests"
        ),
//        Internal core components (ex: logging) not public distributed
        .target(
            name: "Core",
            dependencies: [
                "Domain",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Core/Sources"
//            Unfortunately this doesnt seem to work properly right now.
//            plugins: [
//                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
//            ]
        )
    ]
)
