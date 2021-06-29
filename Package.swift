
// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "Mussel",
    products: [
        .library(name: "Mussel", targets: ["Mussel"])
    ],
    targets: [
        .target(name: "Mussel", path: "Mussel"),
        .testTarget(name: "MusselTests", dependencies: ["Mussel"], path: "MusselTests")
    ]
)