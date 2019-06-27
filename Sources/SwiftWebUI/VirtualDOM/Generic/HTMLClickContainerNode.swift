//
//  HTMLClickContainerNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLClickContainerNode: HTMLWrappingActionNode {
  
  let elementID : ElementID
  let isEnabled : Bool
  let isDouble  : Bool
  let action    : () -> Void
  let content   : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLClickContainerNode(elementID: elementID, isEnabled: isEnabled,
                                  isDouble: isDouble,
                                  action: action, content: newContent)
  }
  
  var clickHandler : String {
    return isDouble ? "ondblclick" : "onclick"
  }
  var onClickValue: String { return "SwiftUI.click(this,event); return false" }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }

    if oldNode.isDouble != isDouble {
      // TODO:
      assertionFailure("not supporting click count change yet.")
    }
    
    if oldNode.isEnabled != isEnabled {
      changeset.append(
        .setAttribute(webID: elementID.webID,
                      attribute: clickHandler,
                      value: isEnabled ? onClickValue : "")
      )
      changeset.append(.init(elementID.webID, toggleClass: "active",
                             isEnabled: isEnabled))
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-click-container"
    if isEnabled { html += " active" }
    html += "\""
    html.appendAttribute("id", elementID.webID)
    if isEnabled { html.appendAttribute(clickHandler, onClickValue) }
    html += ">"
    defer { html += "</div>" }
    
    content.generateHTML(into: &html)
  }
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<ClickHandler \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<ClickHandler/>")
  }
}
