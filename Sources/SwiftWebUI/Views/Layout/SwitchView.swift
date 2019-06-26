//
//  SwitchView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SwitchView<ID: Hashable>: View, CustomStringConvertible {
  // This is necessary if the immediate child of views being swapped out
  // are not a single "div".
  // It also makes sure that the state holders of the old view are flushed.
  // Technically this could be avoid if anything switchable (just dynviews?)
  // are guaranteed to have a div (aka layer, lolz ;-) )
  
  public typealias Body = Never
  
  let content   : AnyView
  let contentID : ID
  
  public init(content: AnyView, contentID: ID) {
    self.content   = content
    self.contentID = contentID
  }
  
  public var description: String {
    return "<SwitchView: \(content)/>"
  }
}
public extension SwitchView where ID == ObjectIdentifier {
  init(_ content: AnyView) {
    self.content   = content
    self.contentID = ObjectIdentifier(content.viewType)
  }
}

extension HTMLTreeBuilder {
  
  func buildTree<ID: Hashable>(for view: SwitchView<ID>,
                               in context: TreeStateContext) -> HTMLTreeNode
  {
    let childTree = _buildContent(view.content, in: context)
    return HTMLSwitchNode(elementID : context.currentElementID,
                          contentID : view.contentID,
                          content   : childTree)
  }
}

extension SwitchView: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
