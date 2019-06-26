//
//  CSSStyles.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import Foundation

public typealias CSSStyles = [ CSSStyleKey : CSSStyleValue ]

public enum CSSStyleKey : String, Hashable {
  // TBD: Technically those allow specific values, a fact we could type out.
  //      But well.
  
  case fontStyle       = "font-style"
  case fontWeight      = "font-weight"
  case fontSize        = "font-size"
  case fontFamily      = "font-family"

  case color           = "color"
  case backgroundColor = "background-color"

  case display         = "display"
  case flexGrow        = "flex-grow"
  case flexDirection   = "flex-direction"
  case alignItems      = "align-items"
  case justifyContent  = "justify-content"
  
  case padding         = "padding"
  case paddingTop      = "padding-top"
  case paddingBottom   = "padding-bottom"
  case paddingLeft     = "padding-left"
  case paddingRight    = "padding-right"

  case border          = "border"
  case borderTop       = "border-top"
  case borderBottom    = "border-bottom"
  case borderLeft      = "border-left"
  case borderRight     = "border-right"
  
  case borderRadius    = "border-radius"

  // really "spacing"
  case vPadding        = "--swiftui-vpadding"
  case hPadding        = "--swiftui-hpadding"

  case height          = "height"
  case width           = "width"
  case minHeight       = "min-height"
  case minWidth        = "min-width"
}

public protocol CSSStyleValue {

  var cssStringValue: String { get }

}

extension Int: CSSStyleValue {

  public var cssStringValue: String { return String(self) }

}
extension String: CSSStyleValue {
  
  public var cssStringValue: String { return self }
  
}

extension CSSStyles {
  
  var cssStringValue: String? {
    guard !isEmpty else { return nil }
    var s = ""
    s.reserveCapacity(count * 20)
    for ( key, value ) in self {
      s += key.rawValue
      s += ": "
      s += value.cssStringValue
      s += ";"
    }
    return s
  }
  
}
