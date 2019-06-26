//
//  HTMLRadioPickerStyle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public typealias RadioGroupPickerStyle = HTMLRadioPickerStyle

public extension StaticMember where Base : PickerStyle {
  static var radioGroup: RadioGroupPickerStyle.Member {
    return .init(base: .init())
  }
}

public struct HTMLRadioPickerStyle : PickerStyle {
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

  fileprivate static let divTag = HTMLTagInfo(tag: "div", attributes: nil,
                                              classes: [ "swiftui-radiogroup" ],
                                              styles: nil)

  func buildTree<S: Hashable>(for view: HTMLRadioPickerStyle.Body<S>,
                              in context: TreeStateContext)
       -> HTMLTreeNode
  {
    let baseID = context.currentElementID
    let configuration = view.configuration
    
    typealias TagTrait = ViewTag<S>
    let ( childTree, traits ) = _buildContent(configuration.body,
                                              collect: TagTrait.self,
                                              in: context)
    
    let currentSelection = configuration.selection.value
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
        print("RadioPicker: missing tag for: \(node)")
        return .replaceAndReturn(newNode: node) // 'keep'?
      }
      
      // Buttons have no active content, so we can reuse the EID here
      let optionNode = HTMLRadioNode(
        baseID: baseID,
        elementID: node.elementID, isEnabled: isEnabled,
        isSelected: currentSelection == tag,
        binding: configuration.selection, tag: tag,
        content: node
      )
      return .replaceAndReturn(newNode: optionNode)
    }

    return FlexBoxStackNode(elementID: baseID, orientation: .vertical,
                            alignment: HorizontalAlignment.leading,
                            spacing: nil, localLayout: nil,
                            content: enrichedChildTree)
  }
}
extension HTMLRadioPickerStyle.Body: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
