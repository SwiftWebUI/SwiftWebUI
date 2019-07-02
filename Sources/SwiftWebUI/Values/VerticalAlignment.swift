//
//  VerticalAlignment.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum VerticalAlignment : Equatable {
  
  case top, center, bottom, firstTextBaseline, lastTextBaseline
  
}

extension VerticalAlignment {

  var flexBoxValue : String {
    
    switch self {
      case .top:    return "flex-start"
      case .center: return "center"
      case .bottom: return "flex-end"
      case .firstTextBaseline, .lastTextBaseline:
        print("WARN: unsupported alignment property:", self)
        return "flex-start"
    }
  }
}
extension VerticalAlignment: CSSStyleValue {
  public var cssStringValue: String { return flexBoxValue }
}
