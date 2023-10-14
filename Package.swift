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
        //.package(url: "git@github.com:nicklockwood/Euclid.git", branch: "main"),
        .package(url: "git@github.com:3Squared/PeakOperation.git", branch: "develop"),
        .package(path: "../Bivouac"),
        .package(path: "../Euclid"),
    ],
    targets: [
        .target(
            name: "Lintel",
            dependencies: ["Bivouac",
                           "Euclid",
                           "PeakOperation"]),
    ]
)
