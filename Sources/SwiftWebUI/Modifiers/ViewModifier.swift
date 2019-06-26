//
//  ViewModifier.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol ViewModifier {
  // We implement this, but it may work quite different to the original.
  
  // associatedtype Body : View
  //func body(content: Self.Content) -> Self.Body
  
  func push(to   context: TreeStateContext)
  func pop (from context: TreeStateContext)
  
  func buildTree<T: View>(for view: T, in context: TreeStateContext)
       -> HTMLTreeNode
}

extension ViewModifier {

  public func push(to   context: TreeStateContext) {}
  public func pop (from context: TreeStateContext) {}

  public func buildTree<T: View>(for view: T, in context: TreeStateContext)
              -> HTMLTreeNode
  {
    return context.currentBuilder.buildTree(for: view, in: context)
  }
}
