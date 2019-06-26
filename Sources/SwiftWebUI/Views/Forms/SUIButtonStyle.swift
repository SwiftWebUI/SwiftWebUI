//
//  SUIButtonStyle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SUIButtonStyle: ButtonStyle {
  
  public typealias Label  = ButtonStyleLabel
  public typealias Member = StaticMember<Self>
  
  public func body(configuration: Button<ButtonStyleLabel>) -> Body {
    return Body(configuration: configuration)
  }
  
  public struct Body: View {
    public typealias Body = Never
    
    let configuration : Button<ButtonStyleLabel>
    
  }
}

extension HTMLTreeBuilder {
  
  func buildTree(for view: SUIButtonStyle.Body, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    let childTree = _buildContent(view.configuration.label, in: context)
    return SUIButtonNode(elementID : context.currentElementID,
                         isEnabled : context.environment.isEnabled,
                         isActive  : false,
                         action    : view.configuration.action,
                         content   : childTree)
  }

}

extension SUIButtonStyle.Body: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
