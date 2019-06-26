//
//  ColorView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

extension Color: View {
  public typealias Body = Never

}

extension Color: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return HTMLColorNode(elementID: context.currentElementID, color: self)
  }
}
