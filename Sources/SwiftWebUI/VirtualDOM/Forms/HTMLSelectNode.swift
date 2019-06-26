//
//  HTMLSelectNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLSelectNode: HTMLWrappingNode {
  
  let elementID  : ElementID
  let isEnabled  : Bool
  let content    : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLSelectNode(elementID: elementID, isEnabled: isEnabled,
                          content: newContent)
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.isEnabled != isEnabled {
      if isEnabled {
        changeset.append(
          .setAttribute(webID: elementID.webID, attribute: "disabled",
                        value: "disabled")
        )
      }
      else {
        changeset.append(
          .removeAttribute(webID: elementID.webID, attribute: "disabled")
        )
      }
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }

  func generateHTML(into html: inout String) {
    // TODO: this wants the 'checked' class
    html += "<select"
    html.appendAttribute("id", elementID.webID)
    html.appendAttribute("onchange", "SwiftUI.selectChanged(this, event);")
    if !isEnabled { html.appendAttribute("disabled", "disabled") }
    html += ">"
    defer { html += "</select>" }
    
    content.generateHTML(into: &html)
  }

  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Select \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<Select/>")
  }
}
