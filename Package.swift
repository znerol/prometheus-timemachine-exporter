// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimeMachineExporter",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.2.0"),
        .package(url: "https://github.com/karwa/swift-url", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/Kitura/HeliumLogger.git", from: "2.0.0"),
        .package(url: "https://github.com/Kitura/Kitura", from: "3.0.0"),
        .package(url: "https://github.com/swift-server-community/SwiftPrometheus.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "timemachine_exporter",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "HeliumLogger", package: "HeliumLogger"),
                .product(name: "Kitura", package: "Kitura"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "SwiftPrometheus", package: "SwiftPrometheus"),
                .product(name: "WebURL", package: "swift-url"),
            ]),
        .testTarget(
            name: "TimeMachineExporterTests",
            dependencies: ["timemachine_exporter"]),
    ]
)
