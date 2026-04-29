// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CVGenerator",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/luizmb/NetworkTools.git", from: "0.1.0"),
        .package(url: "https://github.com/luizmb/FP.git", from: "1.3.0"),
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
