//
//  EdgeInsets.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 09.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum Edge: Int8, CaseIterable, Hashable {
  
  case top, leading, bottom, trailing
 
  public struct Set: OptionSet, Hashable {
    public let rawValue : Int
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    public static let bottom     = Set(rawValue: 1 << 0)
    public static let top        = Set(rawValue: 1 << 1)
    public static let leading    = Set(rawValue: 1 << 2)
    public static let trailing   = Set(rawValue: 1 << 3)
    public static let horizontal = Set(rawValue: 1 << 4)
    public static let vertical   = Set(rawValue: 1 << 5)
    
    public static let all        = Set(rawValue: 1 << 6)
      // TBD: is this all flags, or a special context?
  }
}

public struct EdgeInsets: Hashable {
  public var top: Length, leading: Length, bottom: Length, trailing: Length
  
  public init(_ length: Length) {
    top = length; leading = length; bottom = length; trailing = length
  }
}

extension EdgeInsets: CSSStyleValue {
  
  public var cssStringValue: String { // clockwise in CSS
    return "\(top.cssStringValue) \(trailing.cssStringValue) "
         + "\(bottom.cssStringValue) \(leading.cssStringValue)"
  }
}
