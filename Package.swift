// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MetadataShortenerApi",
    products: [
        .library(
            name: "MetadataShortenerApi",
            targets: ["MetadataShortenerApi"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "metadata-shortener",
            path: "./bindings/xcframework/metadata_shortener.xcframework"
        ),
        .target(
            name: "MetadataShortenerApi",
            dependencies: ["metadata-shortener"],
            path: "Sources"
        ),
        .testTarget(
            name: "Tests",
            dependencies: [
                "MetadataShortenerApi"
            ],
            path: "Tests",
            resources: [
                .process("Resources/kusama-v15-metadata")
            ]
        )
    ]
)
