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
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "Classroom", targets: ["Classroom"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.1.0"
        )
    ],
    targets: [
        .target(
            name: "ReaderCore",
            dependencies: [
                "BibleCore",
                "BibleClient",
                "DirectoryCore",
                "UserDefaultsClient",
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
        ),
        .testTarget(
            name: "AppStoreSnapshotTests",
            dependencies: [
                "ReaderCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: [
                "__Snapshots__"
            ]
        ),
        .target(
            name: "UserDefaultsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "UserDefaultsClientTests",
            dependencies: ["UserDefaultsClient"]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "ReaderCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Classroom",
            dependencies: [
                "BibleCore",
                "BibleClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "ClassroomTests",
            dependencies: [
                "Classroom",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
