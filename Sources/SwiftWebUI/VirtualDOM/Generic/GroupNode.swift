//
//  GroupNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct GroupNode : HTMLWrappingNode {
  
  let elementID : ElementID
  let content   : HTMLTreeNode // type erased, hm
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return GroupNode(elementID: elementID, content: newContent)
  }
  
  var isContentNode  : Bool { return false }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Group>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</Group>")
  }
}
