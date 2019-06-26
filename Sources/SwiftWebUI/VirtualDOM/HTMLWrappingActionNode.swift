//
//  HTMLWrappingActionNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol HTMLWrappingActionNode: HTMLWrappingNode {
  var isEnabled : Bool         { get }
  var action    : () -> Void   { get }
}

extension HTMLWrappingActionNode {
  
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    if elementID.count == webID.count {
      action()
    }
    else {
      try content.invoke(webID, in: context)
    }
  }
  
}
