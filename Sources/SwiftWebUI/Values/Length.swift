//
//  Length.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// TBD: We might want to do this differently for HTML

public enum Length : Hashable {
  
  case pixels        (_ value: Int)
  case percent       (_ value: Float)
  case fontSize      (_ value: Float)
  case parentFontSize(_ value: Float)
 
  public init(_ value: Int) {
    self = .pixels(value)
  }
  public init(_ value: Float) { // this takes 0..1
    self = .percent(value * 100)
  }
}

extension Length: CSSStyleValue {
  
  public var cssStringValue: String {
    switch self {
      case .pixels        (let value): return "\(value)px"
      case .percent       (let value): return "\(value)%"
      case .fontSize      (let value): return "\(value)rem"
      case .parentFontSize(let value): return "\(value)em"
    }
  }
}

extension Length: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .pixels(value)
  }
}
extension Length: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Float) {
    self = .percent(value * 100)
  }
}

extension UXRect {
  
  func insetBy(_ amount: Length) -> UXRect {
    switch amount {
      case .percent(let value):
        let dx = (self.size.width  - self.origin.x) * UXFloat(value) / 100.0
        let dy = (self.size.height - self.origin.y) * UXFloat(value) / 100.0
        return self.insetBy(dx: dx, dy: dy)
      
      case .pixels(let value):
        return self.insetBy(dx: UXFloat(value), dy: UXFloat(value))
      
      default:
        fatalError("only pixels are supported yet")
    }
  }

}
