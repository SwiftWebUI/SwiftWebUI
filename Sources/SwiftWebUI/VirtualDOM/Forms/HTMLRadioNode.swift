//
//  HTMLRadioNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLRadioNode<S: Hashable>: HTMLWrappingNode {
  
  let baseID     : ElementID
  let elementID  : ElementID
  let isEnabled  : Bool
  let isSelected : Bool
  let binding    : Binding<S>
  let tag        : S
  let content    : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLRadioNode(baseID: baseID, elementID: elementID,
                         isEnabled: isEnabled,
                         isSelected: isSelected, binding: binding, tag: tag,
                         content: newContent)
  }
  
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    if elementID.count == webID.count {
      binding.value = tag
      return
    }
    else { // this should be rare
      try content.invoke(webID, in: context)
    }
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    let webID   = elementID.webID
    let inputID = webID + ".X"
    
    func toggleIf(_ flag: Bool, _ key: String) {
      changeset.append(
        flag
        ? .setAttribute   (webID: inputID, attribute: key, value: key)
        : .removeAttribute(webID: inputID, attribute: key)
      )
    }
    
    if oldNode.isEnabled != isEnabled {
      toggleIf(!isEnabled, "disabled")
    }
    
    // TBD: support 'should ignore value change'?
    if oldNode.isSelected != isSelected {
      toggleIf(isSelected, "checked")
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }

  func generateHTML(into html: inout String) {
    let webID   = elementID.webID
    let inputID = webID + ".X"
    
    html += "<div class=\"swiftui-radio\">"
    defer { html += "</div>" }
    
    html += "<input type=\"radio\""
    html.appendAttribute("name",  baseID.webID)
    html.appendAttribute("id",    inputID)
    html.appendAttribute("value", webID) // yeah, not great
    html.appendAttribute("onchange", "SwiftUI.radioChanged(this, event);")
    if isSelected { html.appendAttribute("checked",  "checked")  }
    if !isEnabled { html.appendAttribute("disabled", "disabled") }
    html += " />"
    
    // TODO: this misses a content-replacement ID?
    html += "<label"
    html.appendAttribute("id",  webID)
    html.appendAttribute("for", inputID)
    html += ">"
    defer { html += "</label>"}
    
    content.generateHTML(into: &html)
  }

  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Radio \(elementID.webID) \(isSelected)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<Radio/>")
  }
}
