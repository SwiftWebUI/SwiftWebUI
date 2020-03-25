//
//  RelativeSizeModifiers.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019-2020 Helge Heß. All rights reserved.
//

public extension View {

  func relativeWidth(_ proportion: Length) -> some View {
    typealias M = RelativeLayoutTraitsLayout
    if case .pixels(let value) = proportion { // Hack to make it work w/ Int's
      return modifier(M(width: .percent(Float(value * 100))))
    }
    return modifier(M(width: proportion))
  }
  func relativeHeight(_ proportion: Length) -> some View {
    typealias M = RelativeLayoutTraitsLayout
    if case .pixels(let value) = proportion { // Hack to make it work w/ Int's
      return modifier(M(height: .percent(Float(value * 100))))
    }
    return modifier(M(height: proportion))
  }
}

public struct RelativeLayoutTraitsLayout: ViewModifier {
  
  public enum Content {
    case width(Length)
    case height(Length)
  }
  
  let content : Content
  
  init(width  : Length) { self.content = .width (width)  }
  init(height : Length) { self.content = .height(height) }

  public func push(to context: TreeStateContext) {
    var sizes = context.localLayoutInfo
    switch content {
      case .width (let v): sizes.width  = v
      case .height(let v): sizes.height = v
    }
    context.localLayoutInfo = sizes
  }
  public func pop(from context: TreeStateContext) { }
}
