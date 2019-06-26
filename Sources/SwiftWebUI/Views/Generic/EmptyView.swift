//
//  EmptyView.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct EmptyView : View {
  
  public typealias Body = Never
  
}

extension EmptyView: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return EmptyNode.shared
  }
}
