// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lintel",
    platforms: [.macOS(.v14),
                .iOS(.v17)],
    products: [
        .library(name: "Lintel",
                 targets: ["Lintel"]),
    ],
    dependencies: [
        .package(path: "../Bivouac"),
        .package(path: "../Deltille"),
        .package(url: "git@github.com:nicklockwood/Euclid.git",
                 branch: "develop"),
        .package(url: "git@github.com:3Squared/PeakOperation.git",
                 branch: "master"),
        .package(url: "git@github.com:pointfreeco/swift-dependencies.git",
                 branch: "main")
    ],
    targets: [
        .target(name: "Lintel",
                dependencies: ["Bivouac",
                               "Deltille",
                               .product(name: "Dependencies",
                                        package: "swift-dependencies"),
                               "Euclid",
                               "PeakOperation"]),
    ]
)
