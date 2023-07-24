// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bible",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "BibleClient", targets: ["BibleClient"]),
        .library(name: "BibleCore", targets: ["BibleCore"]),
        .library(name: "ReaderCore", targets: ["ReaderCore"]),
        .library(name: "ComposableTools", targets: ["ComposableTools"]),
        .library(name: "DirectoryCore", targets: ["DirectoryCore"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.56.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: "0.14.1"
        )
    ],
    targets: [
        .target(
            name: "ReaderCore",
            dependencies: [
                "BibleCore",
                "BibleClient",
                "DirectoryCore",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .target(
            name: "DirectoryCore",
            dependencies: [
                "BibleCore",
                "BibleClient",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .target(
            name: "ComposableTools",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .target(
            name: "BibleClient",
            dependencies: [
                "BibleCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "BibleCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "BibleClientTests",
            dependencies: ["BibleClient"]
        )
    ]
)
