//
//  AnyView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct AnyView : View, CustomStringConvertible {

  public typealias Body = Never
  
  #if DEBUG
    private let viewDescription : () -> String
  #endif
  let viewType  : Any.Type
  var bodyBuild : ( TreeStateContext ) -> HTMLTreeNode

  public init<V: View>(_ view: V) {
    #if DEBUG
      self.viewDescription = { return String(describing: view) }
    #endif
    self.viewType = V.self
    self.bodyBuild = { context in
      context.currentBuilder.buildTree(for: view, in: context)
    }
  }
  
  public var description: String {
    #if DEBUG
      return "<AnyView: \(viewDescription())>"
    #else
      return "<AnyView>"
    #endif
  }
}

extension AnyView: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
