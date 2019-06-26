//
//  TraitWritingModifier.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 18.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct TraitWritingModifier<Content: Trait>: ViewModifier {
  
  let content : Content
  
  public func push(to context: TreeStateContext) {
    context.setTrait(content)
  }
  public func pop(from context: TreeStateContext) {
  }
}
