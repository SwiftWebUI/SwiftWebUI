//
//  Font.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 09.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct Font : Hashable {
  
  // TBD: storage + enum
  let style  : TextStyle
  let design : Design
  let size   : Length?
  let name   : String?
  
  private init(_ style: TextStyle, design: Design = .default,
               name: String? = nil, size: Length? = nil)
  {
    self.style  = style
    self.design = design
    self.size   = size
    self.name   = name
  }

  public enum Weight : Hashable {
    case regular
    case ultraLight, thin, light
    case medium, semibold, bold, heavy, black
  }
  
  public enum TextStyle : Hashable, CustomStringConvertible {
    case body
    case largeTitle, title, headline, subheadline, callout
    case footnote, caption
    
    public var description: String {
      switch self {
        case .body:        return "<body>"
        case .largeTitle:  return "<h1>"
        case .title:       return "<h2>"
        case .headline:    return "<hl>"
        case .subheadline: return "<sub>"
        case .callout:     return "<callout>"
        case .footnote:    return "<footnote>"
        case .caption:     return "<caption>"
      }
    }
  }
  
  public enum Design : Hashable, CustomStringConvertible {
    case `default`, serif, rounded, monospaced
    
    public var description: String {
      switch self {
        case .default:    return "default"
        case .serif:      return "serif"
        case .rounded:    return "rounded"
        case .monospaced: return "monospaced"
      }
    }
  }
}

public extension Font {
 
  static func system(_ style: TextStyle, design: Design = .default) -> Font {
    return Font(style, design: design)
  }
  static func system(size: Length, design: Font.Design = .default) -> Font {
    return Font(.body, design: design)
  }
  static func custom(_ name: String, size: Length) -> Font {
    return Font(.body, name: name, size: size)
  }
}

public extension Font {
  static let largeTitle  = Font(.largeTitle)
  static let title       = Font(.title)
  static let headline    = Font(.headline)
  static let subheadline = Font(.subheadline)
  static let body        = Font(.body)
  static let callout     = Font(.callout)
  static let footnote    = Font(.footnote)
  static let caption     = Font(.caption)
}
