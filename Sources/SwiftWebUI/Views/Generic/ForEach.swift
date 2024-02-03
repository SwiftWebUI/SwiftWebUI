//
//  ForEach.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 11.06.19.
//  Copyright © 2019-2024 Helge Heß. All rights reserved.
//

public struct ForEach<Data, Content: View> : DynamicViewContent
                where Data: RandomAccessCollection, Data.Element: Identifiable
{
  // Aka WORepetition
  
  public typealias Body = Never
  
  public let data : Data
  
  let content : ( Data.Element ) -> Content
  
  public init(_ data: Data, content: @escaping ( Data.Element ) -> Content) {
    self.data    = data
    self.content = content
  }
}

extension ForEach: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
