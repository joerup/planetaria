// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlanetariaData",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "PlanetariaData",
            targets: ["PlanetariaData"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/joerup/SwiftSPICE.git", from: "0.7.0")
    ],
    targets: [
        .target(
            name: "PlanetariaData",
            dependencies: ["SwiftSPICE"],
            path: "."
        )
    ]
)
