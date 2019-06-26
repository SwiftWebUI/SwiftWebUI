//
//  SUITextFieldStyle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SUITextFieldStyle: TextFieldStyle {
  
  public typealias Member = StaticMember<Self>
  
  public func body(configuration: TextField) -> Body {
    return Body(configuration: configuration)
  }
  
  public struct Body: View {
    public typealias Body = Never
    
    let configuration : TextField
  }
}

extension HTMLTreeBuilder {
  
  func buildTree(for view: SUITextFieldStyle.Body, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    let configuration = view.configuration
    
    let value = configuration.value.value
    let placeholder : String? = {
      guard let placeholder = configuration.placeholder else { return nil }
      return placeholder.contentString
    }()
    
    return SUIInputNode(elementID        : context.currentElementID,
                        value            : value,
                        binding          : configuration.value,
                        placeholder      : placeholder,
                        isEnabled        : context.environment.isEnabled,
                        isPassword       : configuration.isPassword,
                        onEditingChanged : configuration.onEditingChanged,
                        onCommit         : configuration.onCommit)
  }
}

extension SUITextFieldStyle.Body: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
