//
//  Color.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import Foundation

public enum Color : Hashable, CustomStringConvertible, CSSStyleValue {

  case rgb  (_ value: UInt32)
  case named(_ value: String)
  case clear
  case primary
  case secondary
  
  public init(_ value: UInt32) {
    self = .rgb(value)
  }
  public init(_ s: String) {
    self = .named(s)
  }
  
  var stringValue: String {
    switch self {
      case .rgb(let rgb):
        let red   = String((rgb >> 16) & 0xFF, radix: 16, uppercase: true)
        let green = String((rgb >>  8) & 0xFF, radix: 16, uppercase: true)
        let blue  = String(rgb         & 0xFF, radix: 16, uppercase: true)
        return "#"
             + (red  .count < 2 ? "0" + red : red)
             + (green.count < 2 ? "0" + red : red)
             + (blue .count < 2 ? "0" + red : red)
      
      case .named(let name): return name
      case .clear:           return "rgba(0,0,0,0.0)"
      case .primary:         return "black"
      case .secondary:       return "darkgray"
    }
  }
  
  var htmlStringValue : String { return stringValue }
  public var cssStringValue  : String { return stringValue }
  
  public var description: String {
    return "<Color: \(cssStringValue)>"
  }
}

public extension Color {
  // Add all? ;-)
  // https://www.w3schools.com/colors/colors_names.asp

  static let black     = Color.named("black")
  static let darkGray  = Color.named("darkgray")
  static let gray      = Color.named("gray")
  static let lightGray = Color.named("lightgray")
  static let white     = Color.named("white")

  static let red       = Color.named("red")
  static let green     = Color.named("green")
  static let blue      = Color.named("blue")
  static let yellow    = Color.named("yellow")
  static let purple    = Color.named("purple")
  static let lime      = Color.named("lime")
  static let olive     = Color.named("olive")
  static let navy      = Color.named("navy")
}

extension Color: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: UInt32) {
    self = .rgb(value)
  }
}

extension Color: ExpressibleByStringLiteral {
  public init(stringLiteral s: String) {
    self = .named(s)
  }
}
