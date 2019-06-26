//
//  HorizontalAlignment.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum HorizontalAlignment : Equatable {
  
  case leading, center, trailing
  
}

extension HorizontalAlignment {
  
  var flexBoxValue : String {
    switch self {
      case .leading  : return "flex-start"
      case .center   : return "center"
      case .trailing : return "flex-end"
    }
  }
}

extension HorizontalAlignment: CSSStyleValue {
  public var cssStringValue: String { return flexBoxValue }
}
