// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scaffold",
    products: [
        .executable(name: "scaffold", targets: ["Scaffold"]),
        .library(name: "ScaffoldKit", targets: ["ScaffoldKit"]),
        .library(name: "Parser", targets: ["Parser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.8.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0"), // StencilSwiftKit uses this older version
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.2"),
    ],
    targets: [
        .executableTarget(name: "Scaffold", dependencies: ["ScaffoldKit"]),
        .target(
            name: "ScaffoldKit",
            dependencies: [
                .product(name: "StencilSwiftKit", package: "StencilSwiftKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "PathKit", package: "PathKit"),
                .target(name: "Parser"),
        ]),
        .target(name: "Parser", dependencies: []),
        .testTarget(
            name: "ScaffoldKitTests",
            dependencies: ["ScaffoldKit"]),
    ]
)
