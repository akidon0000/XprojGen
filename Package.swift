// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
// コマンド
// swift run --package-path /{{ PATH }}/MakeXproj make-xproj {{ productName }}

import PackageDescription

let package = Package(
    name: "MakeXproj",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "make-xproj", targets: ["MakeXproj"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.1"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git",  from: "2.40.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
    ],
    targets: [
        .executableTarget(
            name: "MakeXproj",
            dependencies: [
                .product(name: "Stencil", package: "Stencil"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "XcodeGenKit", package: "XcodeGen"),
                .product(name: "ProjectSpec", package: "XcodeGen"),
                .product(name: "Logging", package: "swift-log"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
