// swift-tools-version:5.1

import PackageDescription

let package = Package(
  
  name: "SwiftWebUI",
  
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

enum CombineImplementation {

  case combine, combineX, openCombine

  static var `default`: CombineImplementation {
    #if canImport(Combine)
    return .combine
    #else
    return .combineX
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
}

import Foundation

let env = ProcessInfo.processInfo.environment
let implkey = "CX_COMBINE_IMPLEMENTATION"
let combineImpl = env[implkey].flatMap(CombineImplementation.init) ?? .default

if combineImpl == .combine {
  package.platforms = [.macOS(.v10_15), .iOS(.v13)]
}
