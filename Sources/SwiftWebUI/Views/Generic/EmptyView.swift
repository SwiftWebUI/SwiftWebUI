//
//  EmptyView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct EmptyView : View {
  
  public typealias Body = Never
  
}

extension HTMLTreeBuilder {
  func buildTree(for view: EmptyView, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    return EmptyNode(elementID: context.currentElementID)
  }
}

extension EmptyView: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
