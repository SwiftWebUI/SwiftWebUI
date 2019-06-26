//
//  EmptyNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

final class EmptyNode: HTMLLeafNode {
  
  static let shared = EmptyNode()
  
  var elementID: ElementID { return ElementID.noElementID }
  
  func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Empty/>")
  }
  
  func generateHTML(into html: inout String) {}
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext) {}
}
