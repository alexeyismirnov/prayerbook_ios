// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift_toolkit_calendar",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "swift_toolkit_calendar",
            targets: ["swift_toolkit_calendar"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift", .upToNextMajor(from: "0.14.1")),
    ],
    targets: [
        .target(
            name: "swift_toolkit_calendar",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
            ],
            resources: [.process("Resources")]
        ),
    ]
)
