//
//  HTMLOutputNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLOutputNode: HTMLLeafNode, Equatable {
  
  var elementID : ElementID { return ElementID.noElementID }
  let content   : String
  let escape    : Bool

  init(content: String, escape: Bool) {
    self.content   = content
    self.escape    = escape
  }

  func generateHTML(into html: inout String) {
    if escape {
      html.appendContentHTMLString(content)
    }
    else {
      html.appendContentString(content)
    }
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }

    if oldNode.content != content || oldNode.escape != escape {
      print("WARN: can't change raw HTML views:", self)
    }
  }
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    if escape { print("\(indent)<EscapedHTML: \(content)>") }
    else      { print("\(indent)<HTML: \(content)>")        }
  }
}
