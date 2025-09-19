// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TaboolaSDK_AdX_Adapter",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "TaboolaSDK_AdX_Adapter",
            type: .static,
            targets: ["TaboolaSDK_AdX_Adapter"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads",
            "12.0.0"..<"13.0.0"
        )
    ],
    targets: [
        .target(
            name: "TaboolaSDK_AdX_Adapter",
            dependencies: [
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            path: "TBLAdxPlugin",
            sources: [
                "TBLAdxPlugin.h",
                "TBLAdxPlugin.m"
            ],
            publicHeadersPath: "."
        )
    ]
)
