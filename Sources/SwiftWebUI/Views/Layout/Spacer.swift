//
//  Spacer.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 08.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct Spacer : View, Equatable {
  
  public typealias Body = Never

  public let minLength: Length?
  
  public init(minLength: Length? = nil) {
    self.minLength = minLength
  }
}

extension HTMLTreeBuilder {
  func buildTree(for view: Spacer, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    return FlexBoxSpacerNode(elementID: context.currentElementID,
                             minLength: view.minLength)
  }
}
  
extension Spacer: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }  
}
