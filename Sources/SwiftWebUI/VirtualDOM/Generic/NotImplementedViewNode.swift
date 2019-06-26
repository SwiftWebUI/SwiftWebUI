//
//  NotImplementedView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 08.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

class NotImplementedViewNode : HTMLLeafNode {

  var elementID: ElementID { return ElementID.noElementID }

  func generateHTML(into html: inout String) {
    assertionFailure("NOT IMPLEMENTED")
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    assertionFailure("NOT IMPLEMENTED")
  }

  func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)NOT IMPLEMENTED!");
  }
}
