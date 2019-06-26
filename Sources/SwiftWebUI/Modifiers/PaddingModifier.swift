//
//  Padding.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public extension View {
  
  func padding(_ insets: EdgeInsets) -> ModifiedContent<Self, PaddingLayout> {
    return modifier(PaddingLayout(value: .insets(insets)))
  }
  func padding(_ edges: Edge.Set = .all, _ length: Length? = nil)
       -> ModifiedContent<Self, PaddingLayout>
  {
    return modifier(PaddingLayout(value: .edges(edges, length)))
  }
  func padding(_ length: Length) -> ModifiedContent<Self, PaddingLayout> {
    return modifier(PaddingLayout(value: .insets(EdgeInsets(length))))
  }
}

public struct PaddingLayout: ViewModifier {
  
  public typealias Content = Value
  
  public enum Value: Equatable {
    case insets(EdgeInsets)
    case edges(Edge.Set, Length?)
  }
  
  let value : Value

  public func buildTree<T: View>(for view: T, in context: TreeStateContext)
              -> HTMLTreeNode
  {
    let child = context.currentBuilder._buildInLayoutContext(view, in: context)
    return HTMLPaddingNode(elementID: context.currentElementID,
                           value: value,
                           localLayoutInfo: context.localLayoutInfo,
                           content: child)
  }
  
}
