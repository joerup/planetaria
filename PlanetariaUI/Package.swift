// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlanetariaUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "PlanetariaUI",
            targets: ["PlanetariaUI"]
        )
    ],
    dependencies: [
        .package(path: "../PlanetariaData"),
    ],
    targets: [
        .target(
            name: "PlanetariaUI",
            dependencies: [
                .product(name: "PlanetariaData", package: "PlanetariaData", condition: nil)
            ],
            path: "."
        ),
    ],
    swiftLanguageVersions: [.v5]
)
