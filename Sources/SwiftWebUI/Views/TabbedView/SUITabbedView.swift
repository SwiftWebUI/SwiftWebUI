//
//  SUITabView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 18.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public typealias TabbedView = SUITabbedView

public struct SUITabbedView<SelectionValue: Hashable, Content: View>: View {
  // TODO: this could have two modes, one which re-renders on switch and one
  //       which always pregenerates all tab content.
  //       plus: one which loads on demand ;-)
  
  let selection : Binding<SelectionValue>
  let content   : Content
  
  public init(selection: Binding<SelectionValue>,
              @ViewBuilder content: () -> Content)
  {
    self.selection = selection
    self.content   = content()
  }
  
  public var body: some View { return content }
}

extension TabbedView where SelectionValue == Int {
  
  public init(@ViewBuilder content: () -> Content) {
    // The default if no selection binding is provided
    var selectionHolder = 0
    self.selection = Binding(getValue: { return selectionHolder},
                             setValue: { selectionHolder = $0 })
    self.content   = content()
  }
  
}

extension SUITabbedView: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
