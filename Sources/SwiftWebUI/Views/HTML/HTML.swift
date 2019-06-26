//
//  HTML.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 11.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct HTML : View, Equatable {
  
  public typealias Body = Never

  let content : String
  let escape  : Bool
  
  public init(_ content: String, escape: Bool = false) {
    self.content = content
    self.escape  = escape
  }
  
}

extension HTMLTreeBuilder {
  
  func buildTree(for view: HTML, in context: TreeStateContext) -> HTMLTreeNode
  {
    return HTMLOutputNode(content: view.content, escape: view.escape)
  }
}

extension HTML: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
