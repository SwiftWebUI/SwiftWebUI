// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftWebUI",
    platforms: [
       .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "SwiftWebUI", targets: [ "SwiftWebUI" ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git",
                 from: "2.3.0"),
        .package(url: "https://github.com/SwiftWebResources/SemanticUI-Swift.git",
                 from: "2.3.3"),
        .package(url: "https://github.com/wickwirew/Runtime.git",
                 from: "2.1.0"),
        .package(url: "https://github.com/onmyway133/SwiftHash.git",
                 from: "2.0.2")
                 
    ],
    targets: [
        .target(name: "SwiftWebUI",
                dependencies: [ 
                    "NIO", "NIOHTTP1", "NIOConcurrencyHelpers", 
                    "SwiftHash", "Runtime", "SemanticUI" 
                ])
    ]
)
