// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StatusbarCalendar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "StatusbarCalendar",
            targets: ["StatusbarCalendar"]
        )
    ],
    targets: [
        .executableTarget(
            name: "StatusbarCalendar",
            path: "StatusbarCalendar",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
