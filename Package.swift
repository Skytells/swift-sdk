// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "skytells",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "Skytells",
            targets: ["Skytells"]
        ),
    ],
    targets: [
        .target(
            name: "Skytells",
            path: "Sources/Skytells"
        ),
        .testTarget(
            name: "SkytellsTests",
            dependencies: ["Skytells"],
            path: "Tests/SkytellsTests"
        ),
    ]
)
