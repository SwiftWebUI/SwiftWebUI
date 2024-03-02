//
//  BackgroundModifier.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public extension View {
  
  func background(_ color: Color? = nil , cornerRadius: Length? = nil)
       -> ModifiedContent<Self, BackgroundModifier>
  {
    return modifier(BackgroundModifier(value: ( color, cornerRadius )))
  }
}

public struct BackgroundModifier: ViewModifier {
  // This is very different, we don't do the shape thing yet.
  // ShapeStyle => Shape into View
  // Shape => no accessible inits
  // Presumably Shape would be an SVG thing? But they also use it for
  // clipping etc. So maybe rather CSS
  // So:
  // We just have color and radius :-)

  public typealias Value = ( color: Color?, cornerRadius: Length? )
  
  let value : Value

  
  public func buildTree<T: View>(for view: T, in context: TreeStateContext)
              -> HTMLTreeNode
  {
    context.appendContentElementIDComponent()
    let child = context.currentBuilder.buildTree(for: view, in: context)
    context.deleteLastElementIDComponent()
    
    var styles: CSSStyles? {
      switch ( value.color, value.cornerRadius ) {
        case ( .some(let color), .some(let cornerRadius) ):
          return [ .backgroundColor: color, .borderRadius: cornerRadius ]
        case ( .some(let color), .none ):
          return [ .backgroundColor: color ]
        case ( .none, .some(let cornerRadius) ):
          return [ .borderRadius: cornerRadius ]
        case ( .none, .none ):
          return nil
      }
    }
    
    return HTMLStylePatchingNode.patch(child, withStyles: styles ?? [:], andElementID: context.currentElementID)
  }
  
}
