// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CVGenerator",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/luizmb/NetworkTools.git", branch: "main"),
        .package(url: "https://github.com/luizmb/FP.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "CVGenerator",
            dependencies: [
                .product(name: "HTMLTemplating", package: "NetworkTools"),
                .product(name: "FP", package: "FP"),
            ],
            path: "Sources/CVGenerator"
        )
    ]
)
