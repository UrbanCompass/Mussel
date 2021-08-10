// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Mussel",
    products: [
        .executable(name: "MusselServer", targets: ["MusselServer"]),
        .library(name: "Mussel", targets: ["Mussel"]),
    ],
    targets: [
        .executableTarget(name: "MusselServer"),
        .target(name: "Mussel", dependencies: []),
        .testTarget(name: "MusselTests", dependencies: ["Mussel"]),
    ]
)
