// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "orphandiffs",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/RougeWare/Swift-Simple-Logging", from: "0.5.2"),
        .package(name: "SwiftLibgit2", path: "./lib/RougeWare/SwiftLibgit2"),
//        .package(url: "https://github.com/RougeWare/SwiftLibgit2.git", from: "0.6.0"),
//        .package(url: "https://github.com/RougeWare/SwiftLibgit2.git", branch: "feature/2024-05/Transitionary-refinement"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "orphandiffs",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SimpleLogging", package: "Swift-Simple-Logging"),
                .product(name: "SwiftLibgit2", package: "SwiftLibgit2"),
            ]
        ),
    ]
)



for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(
        .unsafeFlags([
            "-warnings-as-errors",
            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
            "-enable-bare-slash-regex",
        ])
    )
}
