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
        .library(name: "DirectoryCore", targets: ["DirectoryCore"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.0.0"
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
        .testTarget(
            name: "ReaderCoreTests",
            dependencies: [
                "ReaderCore",
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
        .testTarget(
            name: "DirectoryCoreTests",
            dependencies: [
                "DirectoryCore",
                
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
        .testTarget(
            name: "BibleClientTests",
            dependencies: ["BibleClient"]
        ),
        .target(
            name: "BibleCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
