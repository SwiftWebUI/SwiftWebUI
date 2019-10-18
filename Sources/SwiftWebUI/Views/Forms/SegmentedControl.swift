//
//  SegmentedControl.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

//@available(*, unavailable) // enable once ready
public struct SegmentedControl<SelectionValue: Hashable, Content: View>: View {
  // tag based
  // SemanticUI button group
  
  let selection : Binding<SelectionValue>
  let action    : (() -> Void)?
  let content   : Content
  
  public init(selection: Binding<SelectionValue>,
              @ViewBuilder content: () -> Content)
  {
    self.selection = selection
    self.action    = nil
    self.content   = content()
  }
  init(selection: Binding<SelectionValue>, action: @escaping () -> Void,
       content: Content)
  {
    self.selection = selection
    self.action    = action
    self.content   = content
  }
  
  public var body: some View { return content }
}

public extension SegmentedControl {
  func onTapGesture(_ action: @escaping () -> Void) -> Self {
    assert(self.action == nil, "Attempt to override tap action!")
    return SegmentedControl(selection: selection, action: action,
                            content: content)
  }
}

extension HTMLTreeBuilder {
  
  static let segmentedTag = HTMLTagInfo(tag: "div", attributes: nil,
                                        classes: ["ui", "buttons"], styles: nil)
  
  func buildTree<SelectionValue: Hashable, Content: View>(
         for view: SegmentedControl<SelectionValue, Content>,
         in context: TreeStateContext
       ) -> HTMLTreeNode
  {
    typealias TagTrait = ViewTag<SelectionValue>
    let ( childTree, traits ) = _buildContent(view.content,
                                              collect: TagTrait.self,
                                              in: context)
    
    let currentSelection = view.selection.wrappedValue
    let isEnabled = context.environment.isEnabled
    var i = 0
    let enrichedChildTree = childTree.rewrite { node in
      guard node.isContentNode else {
        return .recurse
      }
      
      defer { i += 1 }
      
      let tagOpt : SelectionValue? = traits[node.elementID]?.value ?? {
        if let v = i         as? SelectionValue { return v }
        if let v = String(i) as? SelectionValue { return v }
        return nil
      }()
      guard let tag = tagOpt else {
        print("SegmentedControl: missing tag for: \(node)")
        return .replaceAndReturn(newNode: node) // 'keep'?
      }
      
      // Buttons have no active content, so we can reuse the EID here
      let button = SUIButtonNode(elementID : node.elementID,
                                 isEnabled : isEnabled,
                                 isActive  : currentSelection == tag,
                                 action: {
                                  view.selection.wrappedValue = tag
                                  if let action = view.action {
                                    action()
                                  }
                                 },
                                 content: node)
      
      return .replaceAndReturn(newNode: button)
    }

    let container = HTMLContainerNode(elementID: context.currentElementID,
                                      value: HTMLTreeBuilder.segmentedTag,
                                      content: enrichedChildTree)
    return container
  }
  
}

extension SegmentedControl: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
