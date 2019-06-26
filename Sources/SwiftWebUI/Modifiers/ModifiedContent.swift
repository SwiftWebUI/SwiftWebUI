//
//  ModifiedContent.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 09.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct ModifiedContent<T: View, M: ViewModifier> : View {
  // Our implementation is probably different to what SwiftUI really does.
  // We just put special keys into the context when building the tree.

  public typealias Body = Never

  let content  : T
  let modifier : M
}

extension HTMLTreeBuilder {
  func buildTree<T: View, M: ViewModifier>(
    for view: ModifiedContent<T, M>,
    in context: TreeStateContext
  ) -> HTMLTreeNode
  {
    view.modifier.push(to: context)
    defer { view.modifier.pop(from: context) }
    
    let node = view.modifier.buildTree(for: view.content, in: context)
    return node
  }
}
extension ModifiedContent: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}

public extension View {
  
  typealias Modified<T: ViewModifier> = ModifiedContent<Self, T>
  
  func modifier<T>(_ modifier: T) -> Self.Modified<T> where T: ViewModifier {
    return ModifiedContent(content: self, modifier: modifier)
  }
}
