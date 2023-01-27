// swift-tools-version:5.3
//
// Copyright (c) 2022 Roman Mogutnov (mxrn)
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
            path: "MRFoundation/Sources"
        ),
        .testTarget(
            name: "MRFoundationTests",
            dependencies: ["MRFoundation"],
            path: "MRFoundationTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
