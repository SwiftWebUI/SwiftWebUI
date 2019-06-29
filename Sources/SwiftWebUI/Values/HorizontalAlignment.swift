//
//  HorizontalAlignment.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum HorizontalAlignment : Equatable {
  
  case leading, center, trailing

  /// Hack: Tell a flexbox to stretch its contents.
  ///
  /// This should be automatic depending on the contents of the vstack.
  case stretch
}

extension HorizontalAlignment {
  
  var flexBoxValue : String {
    switch self {
      case .leading  : return "flex-start"
      case .center   : return "center"
      case .trailing : return "flex-end"
      case .stretch  : return "stretch"
    }
  }
}

extension HorizontalAlignment: CSSStyleValue {
  public var cssStringValue: String { return flexBoxValue }
}
