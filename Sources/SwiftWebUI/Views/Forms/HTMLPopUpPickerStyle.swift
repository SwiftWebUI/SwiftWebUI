//
//  HTMLPopUpPickerStyle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public typealias PopUpButtonPickerStyle = HTMLPopUpPickerStyle

public extension StaticMember where Base : PickerStyle {
  static var popUpButton: PopUpButtonPickerStyle.Member {
    return .init(base: .init())
  }
}

public struct HTMLPopUpPickerStyle : PickerStyle {
  // Note: HTML also supports optgroup's (aka sections within popups)
  
  public typealias Member = StaticMember<Self>
  
  public func body<S: Hashable>(configuration: Configuration<S>) -> AnyView {
    return AnyView(Body(configuration: configuration))
  }
  public struct Body<S: Hashable>: View {
    public typealias Body = Never
    let configuration : Configuration<S>
  }
}

extension HTMLTreeBuilder {

  func buildTree<S: Hashable>(for view: HTMLPopUpPickerStyle.Body<S>,
                              in context: TreeStateContext)
       -> HTMLTreeNode
  {
    let baseID        = context.currentElementID
    let configuration = view.configuration
    
    typealias TagTrait = ViewTag<S>
    let ( childTree, traits ) = _buildContent(configuration.body,
                                              collect: TagTrait.self,
                                              in: context)
    
    let currentSelection = configuration.selection.wrappedValue
    let isEnabled = context.environment.isEnabled
    
    var i = 0
    let enrichedChildTree = childTree.rewrite { node in
      guard node.isContentNode else {
        return .recurse
      }
      
      defer { i += 1 }
      
      let tagOpt : S? = traits[node.elementID]?.value ?? {
        if let v = i         as? S { return v }
        if let v = String(i) as? S { return v }
        return nil
      }()
      guard let tag = tagOpt else {
        print("PopUpPicker: missing tag for: \(node)")
        return .replaceAndReturn(newNode: node) // 'keep'?
      }
      
      // Buttons have no active content, so we can reuse the EID here
      let optionNode = HTMLOptionNode(
        baseID: baseID, elementID: node.elementID, isEnabled: isEnabled,
        isSelected: currentSelection == tag,
        binding: configuration.selection, tag: tag,
        content: node
      )
      return .replaceAndReturn(newNode: optionNode)
    }

    context.appendElementIDComponent("|")
    let label = configuration.label.buildTree(in: context)
    context.deleteLastElementIDComponent()

    let selectNode = HTMLSelectNode(elementID : baseID,
                                    isEnabled : isEnabled,
                                    label     : label,
                                    content   : enrichedChildTree)
    return selectNode
  }
}
extension HTMLPopUpPickerStyle.Body: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
