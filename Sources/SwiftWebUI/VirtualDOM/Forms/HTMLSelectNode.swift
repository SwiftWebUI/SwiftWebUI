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
  let label      : HTMLTreeNode
  let content    : HTMLTreeNode

  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLSelectNode(elementID: elementID, isEnabled: isEnabled,
                          label: label,
                          content: newContent)
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.isEnabled != isEnabled {
      if !isEnabled {
        changeset.append(
          .setAttribute(webID: labelWebID, attribute: "disabled",
                        value: "disabled")
        )
      }
      else {
        changeset.append(
          .removeAttribute(webID: labelWebID, attribute: "disabled")
        )
      }
    }
    
    label.generateChanges(from: oldNode.label, into: &changeset, in: context)
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  private var selectWebID : String { return elementID.webID + ".X" }
  private var labelWebID  : String { return elementID.webID + "._" }

  func generateHTML(into html: inout String) {
    // TODO: this wants the 'checked' class
    let webID = elementID.webID
    html += "<div class=\"swiftui-picker\""
    html.appendAttribute("id", webID)
    html += ">"
    defer { html += "</div>" }
    html += "<select"
    html.appendAttribute("id", selectWebID)
    html.appendAttribute("onchange", "SwiftUI.selectChanged(this, event);")
    if !isEnabled { html.appendAttribute("disabled", "disabled") }
    html += ">"
    content.generateHTML(into: &html)
    html += "</select>"

    html += "<label"
    html.appendAttribute("id",  labelWebID)
    html.appendAttribute("for", selectWebID)
    html += ">"
    label.generateHTML(into: &html)
    html += "</label>"
  }

  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Select \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<Select/>")
  }
}
