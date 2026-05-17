// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LocalIPMenuBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "LocalIPMenuBar", targets: ["LocalIPMenuBar"])
    ],
    targets: [
        .target(name: "LocalIPCore"),
        .executableTarget(
            name: "LocalIPMenuBar",
            dependencies: ["LocalIPCore"]
        ),
        .testTarget(
            name: "LocalIPCoreTests",
            dependencies: ["LocalIPCore"]
        )
    ]
)
