// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HTMLTemplating",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "HTMLTemplating", targets: ["HTMLTemplating"]),
    ],
    targets: [
        .target(
            name: "HTMLTemplating",
            path: "Sources/HTMLTemplating"
        ),
    ]
)
