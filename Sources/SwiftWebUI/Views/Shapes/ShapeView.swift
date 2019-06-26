//
//  ShapeView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct ShapeView<Content: Shape, Style: ShapeStyle>: View {
  public typealias Body = Never
  
  public var shape     : Content
  public var style     : Style
}

#if false // @available(*, unavailable)
extension HTMLTreeBuilder {
  
  func buildTree(for view: ShapeView<Rectangle, ForegroundStyle>,
                 in context: TreeStateContext) -> HTMLTreeNode
  {
    // TODO: Render a DIV?
    return NotImplementedViewNode()
  }

}
#endif
