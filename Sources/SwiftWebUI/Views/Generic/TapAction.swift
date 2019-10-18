//
//  TapAction.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public extension View {
  
  func onTapGesture(count: Int = 1, _ action: @escaping () -> Void)
       -> TapActionView<Self>
  {
    assert(count < 2, "only supporting single-click")
    return TapActionView(count: count, action: action, content: self)
  }

}

public struct TapActionView<Content: View>: View {
  public typealias Body = Never
  let count   : Int
  let action  : () -> Void
  let content : Content
}

extension HTMLTreeBuilder {
  
  func buildTree<Content: View>(for view: TapActionView<Content>,
                                in context: TreeStateContext) -> HTMLTreeNode
  {
    let childTree = _buildContent(view.content, in: context)
    return HTMLClickContainerNode(elementID: context.currentElementID,
                                  isEnabled: context.environment.isEnabled,
                                  isDouble: view.count == 2,
                                  action: view.action, content: childTree)
  }
  
}

extension TapActionView: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
