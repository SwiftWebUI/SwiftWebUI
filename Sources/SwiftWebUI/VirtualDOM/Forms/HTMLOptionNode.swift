//
//  HTMLOptionNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLOptionNode<S: Hashable>: HTMLWrappingNode {
  
  let baseID     : ElementID
  let elementID  : ElementID
  let isEnabled  : Bool
  let isSelected : Bool
  let binding    : Binding<S>
  let tag        : S
  let content    : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLOptionNode(baseID: baseID, elementID: elementID,
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
    
    func toggleIf(_ flag: Bool, _ key: String) {
      changeset.append(
        flag
        ? .setAttribute   (webID: elementID.webID, attribute: key, value: key)
        : .removeAttribute(webID: elementID.webID, attribute: key)
      )
    }
    
    if oldNode.isEnabled != isEnabled {
      toggleIf(!isEnabled, "disabled")
    }
    
    // TBD: support 'should ignore value change'?
    if oldNode.isSelected != isSelected {
      if isSelected {
        changeset.append(
          .selectOneOption(selectID: baseID.webID, optionID: elementID.webID)
        )
      }
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }

  func generateHTML(into html: inout String) {
    html += "<option"
    html.appendAttribute("id",    elementID.webID)
    html.appendAttribute("value", elementID.webID) // yeah, not great
    if isSelected { html.appendAttribute("selected", "selected") }
    if !isEnabled { html.appendAttribute("disabled", "disabled") }
    html += ">"
    defer { html += "</option>" }
    
    content.generateHTML(into: &html)
  }

  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Option \(elementID.webID) \(isSelected)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<Option/>")
  }
}
