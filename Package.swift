// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Purchase",
    products: [
        .library(
            name: "Purchase",
            targets: ["AppStoreManager","Purchase"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppStoreManager",
            dependencies: []),
        .target(
            name: "Purchase",
            dependencies: ["AppStoreManager"]),
        .testTarget(
            name: "PurchaseTests",
            dependencies: ["Purchase"]),
    ]
)
