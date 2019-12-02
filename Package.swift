// swift-tools-version:5.1

import PackageDescription

let package = Package(
  
  name: "SwiftWebUI",
  
  platforms: [
    .macOS(.v10_15), .iOS(.v13)
  ],
  
  products: [
    .library   (name: "SwiftWebUI", targets: [ "SwiftWebUI" ]),
    .executable(name: "HolyCow",    targets: [ "HolyCow"    ])
  ],
  
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git",
             from: "2.8.0"),
    .package(url: "https://github.com/SwiftWebResources/SemanticUI-Swift.git",
             from: "2.3.4"),
    .package(url: "https://github.com/wickwirew/Runtime.git",
             from: "2.1.1"),
    .package(url: "https://github.com/cx-org/CombineX.git",
             from: "0.1.0")
  ],
  
  targets: [
    .target(name: "SwiftWebUI",
            dependencies: [ 
                "NIO", "NIOHTTP1", "NIOConcurrencyHelpers", 
                "Runtime", "SemanticUI", "CXShim"
            ]),
    .target(name: "HolyCow", dependencies: [ "SwiftWebUI" ])
  ]
)
