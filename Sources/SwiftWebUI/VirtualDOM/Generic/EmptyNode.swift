//
//  EmptyNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct EmptyNode: HTMLLeafNode {
  // Note: This still needs an ID, if used in an if-else ViewBuilder, the
  //       changes will try to replace the ID with the other contents.
  
  let elementID: ElementID
  
  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-empty\""
    html.appendAttribute("id", elementID.webID)
    html += "></div>"
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let _ = sameType(oldNode, &changeset) else { return }
    // both empty
  }
  
  func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Empty/>")
  }
}
