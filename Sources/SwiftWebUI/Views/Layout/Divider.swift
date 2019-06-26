//
//  Divider.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct Divider : View, Equatable {
  
  public typealias Body = Never
  
  public init() {}
}

extension HTMLTreeBuilder {
  
  func buildTree(for view: Divider, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    // TBD: Direction?
    return HTMLOutputNode(content: "<div class=\"ui divider\"></div>",
                          escape: false)
  }
}

extension Divider: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
