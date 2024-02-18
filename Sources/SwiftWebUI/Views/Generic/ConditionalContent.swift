//
//  ConditionalContent.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct ConditionalContent<TrueContent, FalseContent> : View
         where TrueContent : View, FalseContent : View
{
  // When building, we only ever get one side, either True or False.
  // That means if the condition toggles, the full child tree won't
  // match up anymore? (unless they have an identical structure?)
  public typealias Body = Never
  
  enum Content {
    case first(TrueContent)
    case second(FalseContent)
  }
  let content : Content
  
  init(first  : TrueContent)  { content = .first(first)   }
  init(second : FalseContent) { content = .second(second) }

}

extension ConditionalContent: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
