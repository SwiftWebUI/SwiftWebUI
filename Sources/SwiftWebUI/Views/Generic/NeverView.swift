//
//  NeverView.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

extension Never : View {

  public var body : Never { fatalError("no body in Never") }
  
}

extension View where Body == Never {
  public var body : Never { fatalError("no body in \(type(of: self))") }
}

extension Never: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return EmptyNode(elementID: context.currentElementID)
  }
}
