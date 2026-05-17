// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ExposeIPAddress",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ExposeIPAddress", targets: ["ExposeIPAddress"])
    ],
    targets: [
        .target(
            name: "LocalIPCore",
            linkerSettings: [
                .linkedFramework("SystemConfiguration")
            ]
        ),
        .executableTarget(
            name: "ExposeIPAddress",
            dependencies: ["LocalIPCore"],
            linkerSettings: [
                .linkedFramework("ServiceManagement")
            ]
        ),
        .testTarget(
            name: "LocalIPCoreTests",
            dependencies: ["LocalIPCore"]
        )
    ]
)
