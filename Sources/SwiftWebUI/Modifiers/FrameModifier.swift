//
//  FrameModifier.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public extension View {
  
  func frame(width: Length? = nil, height: Length? = nil,
             alignment: Alignment = .center)
       -> ModifiedContent<Self, FrameLayout>
  {
    return modifier(FrameLayout(value:
            .init(width: width, height: height, alignment: alignment)))
  }
}

public struct FrameLayout: ViewModifier {
  
  public typealias Content = Value
  
  public struct Value: Equatable {
    let width     : Length?
    let height    : Length?
    let alignment : Alignment
  }
  
  let value : Value

  public func buildTree<T: View>(for view: T, in context: TreeStateContext)
              -> HTMLTreeNode
  {
    context.appendContentElementIDComponent()
    let child = context.currentBuilder.buildTree(for: view, in: context)
    context.deleteLastElementIDComponent()
    
    return HTMLFrameNode(elementID: context.currentElementID,
                         value: value, content: child)
  }
  
}
