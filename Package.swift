// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "scaffold", // TODO: move all deps and real code to ScaffoldKit
    dependencies: [
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.7.2"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.2"), // StencilSwiftKit uses this older version
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.5"),
        // TODO: add this to automatically add to xcodeproj? https://github.com/tuist/XcodeProj.git
    ],
    targets: [
        .target(
            name: "scaffold",
            dependencies: [
                .product(name: "StencilSwiftKit", package: "StencilSwiftKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "PathKit", package: "PathKit"),
            ]),
        .testTarget(
            name: "scaffoldTests",
            dependencies: ["scaffold"]),
    ]
)
