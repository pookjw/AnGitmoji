// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnGitMojiResourcesScript",
    platforms: [.macOS(.v11)],
    dependencies: [
      .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.4")
    ],
    targets: [
        .executableTarget(
            name: "AnGitMojiResourcesScript",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
