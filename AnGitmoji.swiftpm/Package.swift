// swift-tools-version: 5.7

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "AnGitmoji",
    platforms: [
        .iOS("16.0"),
        .macCatalyst("16.0")
    ],
    products: [
        .iOSApplication(
            name: "AnGitmoji",
            targets: ["AnGitmoji"],
            bundleIdentifier: "com.pookjw.angitmoji",
            teamIdentifier: "P53D29U9LJ",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .cat),
            accentColor: .presetColor(.purple),
            supportedDeviceFamilies: [
                .pad,
                .phone,
                .mac
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            appCategory: .utilities
        )
    ],
    targets: [
        .executableTarget(
            name: "AnGitmoji",
            dependencies: [
                "AnGitmojiCore"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AnGitmojiCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AnGitmojiCoreTests",
            dependencies: [
                "AnGitmojiCore"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)