//
//  HStack.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 08.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct HStack<Content: View> : View, CustomStringConvertible {
  public typealias Body = Never

  let alignment : VerticalAlignment
  let spacing   : Length?
  let content   : Content
  
  public var description: String {
    if let spacing = spacing {
      return "<HStack: \(alignment) \(spacing): \(content)>"
    }
    else {
      return "<HStack: \(alignment): \(content)>"
    }
  }
  
  public init(alignment: VerticalAlignment = .center,
              spacing: Length? = nil, @ViewBuilder content: () -> Content)
  {
    self.alignment = alignment
    self.spacing   = spacing
    self.content   = content()
  }
}

extension HStack: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
