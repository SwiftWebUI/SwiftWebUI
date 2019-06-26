//
//  SUIToggleStyle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SUIToggleStyle: ToggleStyle {
  
  public typealias Label  = ToggleStyleLabel
  public typealias Member = StaticMember<Self>
  
  public func body(configuration: Toggle<Label>) -> Body {
    return Body(configuration: configuration)
  }
  
  public struct Body: View {
    public typealias Body = Never
    
    let configuration : Toggle<Label>
  }
}

extension HTMLTreeBuilder {
  
  func buildTree(for view: SUIToggleStyle.Body, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    let configuration = view.configuration
    
    context.appendContentElementIDComponent()
    let childTree = configuration.label.buildTree(in: context)
    context.deleteLastElementIDComponent()
    
    return SUIToggleNode(elementID : context.currentElementID,
                         isEnabled : context.environment.isEnabled,
                         isOn      : configuration.isOn.value,
                         binding   : configuration.isOn,
                         content   : childTree)
  }
}

extension SUIToggleStyle.Body: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
