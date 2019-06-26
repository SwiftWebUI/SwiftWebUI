//
//  ScrollView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct ScrollView<Content: View> : View, CustomStringConvertible {
  public typealias Body = Never
  
  // TODO: support the properties we can?
  
  let content: Content
  
  public init(@ViewBuilder content: () -> Content) {
    self.content   = content()
  }

  public var description: String {
    return "<ScrollView/>"
  }
}

extension ScrollView: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
