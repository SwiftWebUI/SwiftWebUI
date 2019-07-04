// swift-tools-version:5.1

import PackageDescription

#if canImport(Combine)
  let extraPackages     : [ PackageDescription.Package.Dependency ] = []
  let extraDependencies : [ Target.Dependency ] = []
#else
  let extraPackages     : [ PackageDescription.Package.Dependency ] = [
    .package(url: "https://github.com/broadwaylamb/OpenCombine.git",
             .branch("master"))
  ]
  let extraDependencies : [ Target.Dependency ] = [ "OpenCombine" ]
#endif

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
             from: "2.3.0"),
    .package(url: "https://github.com/SwiftWebResources/SemanticUI-Swift.git",
             from: "2.3.4"),
    .package(url: "https://github.com/wickwirew/Runtime.git",
             from: "2.1.0")
  ] + extraPackages,
  
  targets: [
    .target(name: "SwiftWebUI",
            dependencies: [ 
                "NIO", "NIOHTTP1", "NIOConcurrencyHelpers", 
                "Runtime", "SemanticUI" 
            ] + extraDependencies),
    .target(name: "HolyCow", dependencies: [ "SwiftWebUI" ])
  ]
)
