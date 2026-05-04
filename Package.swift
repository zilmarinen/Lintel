// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lintel",
    platforms: [.macOS(.v15),
                .iOS(.v17)],
    products: [
        .library(name: "Lintel",
                 targets: ["Lintel"]),
    ],
    dependencies: [
        .package(path: "../Alluvium"),
        .package(path: "../Bivouac"),
        .package(url: "git@github.com:zilmarinen/Deltille.git",
                 branch: "main"),
        .package(url: "git@github.com:nicklockwood/Euclid.git",
                 branch: "main"),
    ],
    targets: [
        .target(name: "Lintel",
                dependencies: ["Alluvium",
                               "Bivouac",
                               "Deltille",
                               "Euclid"]),
    ]
)
