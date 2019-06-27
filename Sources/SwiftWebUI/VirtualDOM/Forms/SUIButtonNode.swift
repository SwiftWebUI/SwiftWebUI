//
//  SUIButtonNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUIButtonNode: HTMLWrappingActionNode {
  
  let elementID : ElementID
  let isEnabled : Bool
  let isActive  : Bool
  let action    : () -> Void
  let content   : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return SUIButtonNode(elementID: elementID, isEnabled: isEnabled,
                         isActive: isActive, action: action,
                         content: newContent)
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.isEnabled != isEnabled {
      changeset.append(
        .init(elementID.webID, toggleClass: "disabled", isEnabled: !isEnabled)
      )
    }
    if oldNode.isActive != isActive {
      changeset.append(
        .init(elementID.webID, toggleClass: "active", isEnabled: isActive)
      )
    }

    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  func generateHTML(into html: inout String) {
    let disabledClass = isEnabled ? "" : " disabled"
    let activeClass   = isActive  ? " active" : ""
    html += "<button "
    html += "class=\"swiftui-button ui button\(disabledClass)\(activeClass)\""
    html.appendAttribute("id", elementID.webID)
    html.appendAttribute("onclick", "SwiftUI.click(this,event);return false")
    html += ">"
    defer { html += "</button>" }
    
    content.generateHTML(into: &html)
  }
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Button \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<Button/>")
  }
}
