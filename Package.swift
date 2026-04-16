// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CVGenerator",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "Packages/HTMLTemplating"),
    ],
    targets: [
        .executableTarget(
            name: "CVGenerator",
            dependencies: ["HTMLTemplating"],
            path: "Sources/CVGenerator"
        )
    ]
)
