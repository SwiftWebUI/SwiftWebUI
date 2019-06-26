//
//  VStack.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct VStack<Content: View> : View, CustomStringConvertible {
  public typealias Body = Never

  let alignment : HorizontalAlignment
  let spacing   : Length?
  let content   : Content

  public init(alignment: HorizontalAlignment = .center,
              spacing: Length? = nil, @ViewBuilder content: () -> Content)
  {
    self.alignment = alignment
    self.spacing   = spacing
    self.content   = content()
  }

  public var description: String {
    if let spacing = spacing {
      return "<VStack: \(alignment) \(spacing): \(content)>"
    }
    else {
      return "<VStack: \(alignment): \(content)>"
    }
  }
}

extension VStack: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
