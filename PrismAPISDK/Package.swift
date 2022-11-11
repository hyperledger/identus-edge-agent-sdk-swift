// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PrismAPI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "PrismAPI",
            targets: ["PrismAPI"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PrismAPI",
            path: "./PrismAPI.xcframework"
        ),
    ]
)
