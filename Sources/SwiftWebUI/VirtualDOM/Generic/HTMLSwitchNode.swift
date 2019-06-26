//
//  HTMLSwitchNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLSwitchNode<ID: Hashable> : HTMLWrappingNode {
  
  let elementID : ElementID
  let contentID : ID
  let content   : HTMLTreeNode // type erased, hm
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLSwitchNode(elementID: elementID, contentID: contentID,
                          content: newContent)
  }

  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.contentID != contentID {
      #if false // THIS IS WRONG
        // At this point we already bound the new StateHolder as part of the
        // tree generation process.
        context.nodeGotDeleted(elementID) // clear now invalid state
      #endif
      
      var html = ""
      content.generateHTML(into: &html)
      let change = HTMLChange
        .replaceElementContentsWithHTML(webID: elementID.webID, html: html)
      changeset.append(change)
    }
    else {
      content.generateChanges(from: oldNode.content, into: &changeset,
                              in: context)
    }
  }

  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-switch\""
    html.appendAttribute("id", elementID.webID)
    html += ">"
    defer { html += "</div>" }
    
    content.generateHTML(into: &html)
  }
  
  // MARK: - Debug
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Scroller>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</Scroller>")
  }
}
