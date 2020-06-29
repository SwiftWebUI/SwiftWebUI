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
             from: "2.17.0"),
    .package(url: "https://github.com/SwiftWebResources/SemanticUI-Swift.git",
             from: "2.3.4"),
    .package(url: "https://github.com/wickwirew/Runtime.git",
             from: "2.1.1"),
  ],
  
  targets: [
    .target(name: "SwiftWebUI",
            dependencies: [ 
                "NIO", "NIOHTTP1", "NIOConcurrencyHelpers", 
                "Runtime", "SemanticUI"
            ]),
    .target(name: "HolyCow", dependencies: [ "SwiftWebUI" ])
  ]
)

enum CombineImplementation {

  case combine, combineX, openCombine

  static var `default`: CombineImplementation {
    #if canImport(Combine)
    return .combine
    #else
    return .openCombine
    #endif
  }

  init?(_ description: String) {
    let desc = description.lowercased().filter { $0.isLetter }
    switch desc {
    case "combine":     self = .combine
    case "combinex":    self = .combineX
    case "opencombine": self = .openCombine
    default:            return nil
    }
  }
    
  var extraPackageDependencies: [Package.Dependency] {
    switch self {
    case .combine:      return []
    case .combineX:     return [.package(url: "https://github.com/cx-org/CombineX.git", .upToNextMinor(from: "0.1.0"))]
    case .openCombine:  return [.package(url: "https://github.com/broadwaylamb/OpenCombine", .exact("0.5.0"))]
    }
  }
  
  var shimTargetDependencies: [Target.Dependency] {
    switch self {
    case .combine:      return []
    case .combineX:     return ["CombineX"]
    case .openCombine:  return ["OpenCombine", "OpenCombineDispatch"]
    }
  }
  
  var swiftSettings: [SwiftSetting] {
    switch self {
    case .combine:      return [.define("USE_COMBINE")]
    case .combineX:     return [.define("USE_COMBINEX")]
    case .openCombine:  return [.define("USE_OPEN_COMBINE")]
    }
  }
}

import Foundation

let env = ProcessInfo.processInfo.environment
let implkey = "CX_COMBINE_IMPLEMENTATION"
let combineImpl = env[implkey].flatMap(CombineImplementation.init) ?? .default

package.dependencies += combineImpl.extraPackageDependencies
let target = package.targets.first { $0.name == "SwiftWebUI" }
target?.dependencies += combineImpl.shimTargetDependencies
target?.swiftSettings = combineImpl.swiftSettings
