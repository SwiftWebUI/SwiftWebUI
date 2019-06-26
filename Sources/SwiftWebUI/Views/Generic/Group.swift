//
//  Group.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 16.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct Group<Content: View> : View {
  
  public typealias Body = Never
  
  let content : Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
}

extension Group: CustomStringConvertible {
  public var description: String { return "<Group: \(content)>" }
}

extension Group: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
