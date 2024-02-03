// swift-tools-version:5.5

import PackageDescription

#if canImport(Combine)
  let extraPackages     : [ PackageDescription.Package.Dependency ] = []
  let extraDependencies : [ Target.Dependency ] = []
#else
  let extraPackages     : [ PackageDescription.Package.Dependency ] = [
    .package(url: "https://github.com/OpenCombine/OpenCombine.git",
             from: "0.5.0")
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
             from: "2.46.0"),
    .package(url: "https://github.com/SwiftWebResources/SemanticUI-Swift.git",
             from: "2.4.2"),
    .package(url: "https://github.com/wickwirew/Runtime.git",
             from: "2.2.4")
  ] + extraPackages,
  
  targets: [
    .target(name: "SwiftWebUI",
            dependencies: [ 
              .product(name: "NIO",                   package: "swift-nio"),
              .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
              .product(name: "NIOHTTP1",              package: "swift-nio"),
              .product(name: "SemanticUI", package: "SemanticUI-Swift"),
              "Runtime"
            ] + extraDependencies,
            exclude: [ "Views/Shapes/README.md" ]
    ),
    .executableTarget(name: "HolyCow", dependencies: [ "SwiftWebUI" ])
  ]
)
