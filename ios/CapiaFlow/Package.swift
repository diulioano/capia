// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CapiaFlow",
    products: [.library(name: "CapiaFlow", targets: ["CapiaFlow"])],
    targets: [
        .target(name: "CapiaFlow"),
        .testTarget(name: "CapiaFlowTests", dependencies: ["CapiaFlow"])
    ],
    swiftLanguageModes: [.v6]
)
