//
//  Path.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum Path : Equatable {
  // TODO: Presumably we could support any kind of Path via SVG, and potentially
  //       CSS. Which can also mask & clip using pathes.
  
  case rect       (_ bounds: UXRect)
  case roundedRect(_ bounds: UXRect, cornerRadius: Length)

  public init(_ rect: UXRect) {
    self = .rect(rect)
  }
  public init(roundedRect bounds: UXRect, cornerRadius: Length) {
    self = .roundedRect(bounds, cornerRadius: cornerRadius)
  }
  
  public var isEmpty: Bool { return false }
  
  public var boundingRect: UXRect {
    switch self {
      case .rect       (let bounds):    return bounds
      case .roundedRect(let bounds, _): return bounds
    }
  }
}

extension Path: Shape {
  
  public func path(in rect: UXRect) -> Path {
    // TBD: Should that scale our rect values?? Or center? Or what? :-)
    switch self {
      case .rect:
        return Path(rect)
      case .roundedRect(_, let cornerRadius):
        return Path(roundedRect: rect, cornerRadius: cornerRadius)
    }
  }
  
}

