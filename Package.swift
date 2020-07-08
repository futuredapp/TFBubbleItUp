// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TFBubbleItUp",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "TFBubbleItUp", targets: ["TFBubbleItUp"])
    ],
    targets: [
        .target(name: "TFBubbleItUp")
    ]
)
