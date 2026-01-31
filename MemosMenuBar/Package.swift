// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MemosMenuBar",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MemosMenuBar", targets: ["MemosMenuBar"])
    ],
    targets: [
        .executableTarget(
            name: "MemosMenuBar",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
