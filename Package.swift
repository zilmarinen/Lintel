// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lintel",
    platforms: [.macOS(.v11),
                .iOS(.v13)],
    products: [
        .library(
            name: "Lintel",
            targets: ["Lintel"]),
    ],
    dependencies: [
        .package(url: "git@github.com:nicklockwood/Euclid.git", branch: "main"),
                .package(path: "../Bivouac"),
    ],
    targets: [
        .target(
            name: "Lintel",
            dependencies: ["Bivouac", "Euclid"]),
    ]
)
