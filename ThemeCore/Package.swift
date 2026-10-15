// swift-tools-version: 5.9
// Linux-buildable slice of iPlayr's theme system: colour maths, the theme
// table, mode tokens, selection/migration/picker logic and wheel geometry.
// Sources/ThemeCore is a symlink to iPlayr/iPlayr/Core/Theme/ThemeCore, so the
// package and the Xcode app compile the very same files.
import PackageDescription

let package = Package(
    name: "ThemeCore",
    targets: [
        .target(name: "ThemeCore", path: "Sources/ThemeCore"),
        .testTarget(name: "ThemeCoreTests", dependencies: ["ThemeCore"], path: "Tests/ThemeCoreTests"),
    ]
)
