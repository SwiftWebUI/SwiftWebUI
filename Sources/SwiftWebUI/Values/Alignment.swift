//
//  Alignment.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum Alignment : Equatable {
  
  case center, leading, trailing, top, bottom
  case topLeading, topTrailing, bottomLeading, bottomTrailing
  
  public var horizontal : HorizontalAlignment {
    switch self {
      case .center,   .top,         .bottom:         return .center
      case .leading,  .topLeading,  .bottomLeading:  return .leading
      case .trailing, .topTrailing, .bottomTrailing: return .trailing
    }
  }
  public var vertical : VerticalAlignment {
    switch self {
      case .center, .leading,       .trailing:       return .center
      case .top,    .topLeading,    .topTrailing:    return .top
      case .bottom, .bottomLeading, .bottomTrailing: return .bottom
    }
  }
  
  public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
    switch ( horizontal, vertical ) {
      case ( .center,   .center ): self = .center
      case ( .leading,  .center ): self = .leading
      case ( .trailing, .center ): self = .trailing
      case ( .center,   .top    ): self = .top
      case ( .center,   .bottom ): self = .bottom
      case ( .leading,  .top    ): self = .topLeading
      case ( .trailing, .top    ): self = .topTrailing
      case ( .leading,  .bottom ): self = .bottomLeading
      case ( .trailing, .bottom ): self = .bottomTrailing
      
      // TBD:
      case ( .leading,  .firstTextBaseline ): self = .topLeading
      case ( .trailing, .firstTextBaseline ): self = .topTrailing
      case ( .center,   .firstTextBaseline ): self = .top
      case ( .leading,  .lastTextBaseline  ): self = .bottomLeading
      case ( .trailing, .lastTextBaseline  ): self = .bottomTrailing
      case ( .center,   .lastTextBaseline  ): self = .bottom
    }
  }
}
