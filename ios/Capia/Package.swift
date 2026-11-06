// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Capia",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // An xtool project should contain exactly one library product,
        // representing the main app.
        .library(
            name: "Capia",
            targets: ["Capia"]
        ),
    ],
    dependencies: [.package(path: "../CapiaFlow")],
    targets: [
        .target(
            name: "Capia",
            dependencies: ["CapiaFlow"],
            exclude: ["Resources/SOURCES.md", "Resources/sources.json"],
            resources: [.process("Resources/Images"), .process("Resources/Fonts")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
