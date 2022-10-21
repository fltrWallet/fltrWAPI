// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "fltrWAPI",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "fltrWAPI",
            targets: ["fltrWAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/fltrWallet/bech32", branch: "main"),
        .package(url: "https://github.com/fltrWallet/fltrTx", branch: "main"),
    ],
    targets: [
        .target(
            name: "fltrWAPI",
            dependencies: [
                "bech32",
                "fltrTx",
            ]),
    ]
)
