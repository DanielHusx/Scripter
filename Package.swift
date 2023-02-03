// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scripter",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "Scripter",
            targets: ["Scripter"]),
    ],
    targets: [
        .target(
            name: "Scripter",
            path: "Sources",
            resources: [.process("Resources")]),
        .testTarget(
            name: "ScripterTests",
            dependencies: ["Scripter"],
            path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
