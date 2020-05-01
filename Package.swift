// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CombinePublisherTests",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "CustomPublishers", targets: ["CustomPublishers"]),
    ],
    targets: [
        .target(name: "CustomPublishers"),
        .testTarget(name: "CombinePublisherTests", dependencies: ["CustomPublishers"]),
    ]
)
