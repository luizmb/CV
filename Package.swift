// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CVGenerator",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "CVGenerator",
            path: "Sources/CVGenerator",
            resources: [
                .copy("../../Resources")
            ]
        )
    ]
)
