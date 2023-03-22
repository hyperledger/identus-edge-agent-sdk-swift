// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtalaPRISMSDK",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "AtalaPrismSDK",
            targets: [
                "AtalaPrismSDK",
                "Domain",
                "Castor",
                "Apollo",
                "Mercury",
                "Pluto",
                "Pollux",
                "PrismAgent"
            ]
        ),
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
        .package(url: "git@github.com:apple/swift-protobuf.git", from: "1.7.0"),
        .package(url: "git@github.com:antlr/antlr4.git", exact: "4.12.0"),
        .package(url: "git@github.com:input-output-hk/atala-prism-didcomm-swift.git", from: "0.3.6"),
        .package(url: "git@github.com:swift-libp2p/swift-multibase.git", branch: "main"),
        .package(url: "git@github.com:GigaBitcoin/secp256k1.swift.git", from: "0.10.0"),
        .package(url: "git@github.com:goncalo-frade-iohk/Swift-JWT.git", from: "4.1.3")
    ],
    targets: [
        .target(
            name: "AtalaPrismSDK",
            dependencies: [
                "Domain",
                "Castor",
                "Apollo",
                "Mercury",
                "Pluto",
                "Pollux",
                "PrismAgent"
            ],
            path: "AtalaPrismSDK/AtalaPrismSDK/Sources"
        ),
        .target(
            name: "Domain",
            path: "AtalaPrismSDK/Domain/Sources"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            path: "AtalaPrismSDK/Domain/Tests"
        ),
        .target(
            name: "Apollo",
            dependencies: [
                "Domain",
                "Core",
                .product(name: "secp256k1", package: "secp256k1.swift")
            ],
            path: "AtalaPrismSDK/Apollo/Sources"
        ),
        .testTarget(
            name: "ApolloTests",
            dependencies: ["Apollo"],
            path: "AtalaPrismSDK/Apollo/Tests"
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
            path: "AtalaPrismSDK/Castor/Sources"
        ),
        .testTarget(
            name: "CastorTests",
            dependencies: ["Castor", "Apollo"],
            path: "AtalaPrismSDK/Castor/Tests"
        ),
        .target(
            name: "Pollux",
            dependencies: [
                "Domain",
                "Core",
                .product(name: "SwiftJWT", package: "Swift-JWT")
            ],
            path: "AtalaPrismSDK/Pollux/Sources"
        ),
        .testTarget(
            name: "PolluxTests",
            dependencies: ["Pollux", "Apollo", "Castor"],
            path: "AtalaPrismSDK/Pollux/Tests"
        ),
        .target(
            name: "Mercury",
            dependencies: [
                "Domain",
                "Core",
                .product(name: "DIDCommxSwift", package: "atala-prism-didcomm-swift")
            ],
            path: "AtalaPrismSDK/Mercury/Sources"
        ),
        .testTarget(
            name: "MercuryTests",
            dependencies: ["Mercury"],
            path: "AtalaPrismSDK/Mercury/Tests"
        ),
        .target(
            name: "Pluto",
            dependencies: ["Domain"],
            path: "AtalaPrismSDK/Pluto/Sources",
            resources: [.process("Resources/PrismPluto.xcdatamodeld")]
        ),
        .testTarget(
            name: "PlutoTests",
            dependencies: ["Pluto"],
            path: "AtalaPrismSDK/Pluto/Tests"
        ),
        .target(
            name: "Builders",
            dependencies: ["Domain", "Castor", "Pollux", "Mercury", "Pluto", "Apollo"],
            path: "AtalaPrismSDK/Builders/Sources"
        ),
        .target(
            name: "PrismAgent",
            dependencies: [
                "Domain",
                "Builders",
                "Core",
                .product(name: "SwiftJWT", package: "Swift-JWT")
            ],
            path: "AtalaPrismSDK/PrismAgent/Sources"
        ),
        .testTarget(
            name: "PrismAgentTests",
            dependencies: ["PrismAgent"],
            path: "AtalaPrismSDK/PrismAgent/Tests"
        ),
        .target(
            name: "Authenticate",
            dependencies: ["Domain", "Builders", "Core"],
            path: "AtalaPrismSDK/Authenticate/Sources"
        ),
        .testTarget(
            name: "AuthenticateTests",
            dependencies: ["Authenticate"],
            path: "AtalaPrismSDK/Authenticate/Tests"
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
