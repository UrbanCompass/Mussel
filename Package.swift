
// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "Mussel",
    products: [
        .library(name: "Mussel", targets: ["Mussel"])
    ],
    targets: [
        .target(name: "Mussel", path: "Mussel/Mussel", exclude: ["BuiltProduct", "Info.plist"]),
        .testTarget(name: "MusselTests", dependencies: ["Mussel"], path: "Mussel/MusselTests", exclude: ["Info.plist"])
    ]
)
