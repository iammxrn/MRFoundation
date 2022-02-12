// swift-tools-version:5.3
//
// Copyright (c) 2022 Roman Mogutnov (Mix-Roman)
//

import PackageDescription

let package = Package(
    name: "MRFoundation",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "MRFoundation",
            targets: ["MRFoundation"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MRFoundation",
            dependencies: [],
            path: "MRFoundation/Sources"),
    ],
    swiftLanguageVersions: [.v5]
)
