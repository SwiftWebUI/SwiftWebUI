//
//  ModifiedContent.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 09.06.19.
//  Copyright © 2019-2020 Helge Heß. All rights reserved.
//

public struct ModifiedContent<Content, Modifier> {
  
  public var content  : Content
  public var modifier : Modifier
  
  @inlinable
  init(content: Content, modifier: Modifier) {
    self.content  = content
    self.modifier = modifier
  }
}
extension ModifiedContent: View
            where Content: View, Modifier: ViewModifier
{
  public typealias Body = Never
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
extension ModifiedContent: TreeBuildingView
            where Content: View, Modifier: ViewModifier
{
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
