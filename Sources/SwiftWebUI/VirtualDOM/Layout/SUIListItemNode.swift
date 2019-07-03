//
//  SUIListItemNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUIListItemNode<Selection: SelectionManager>: HTMLWrappingNode {
  
  let elementID  : ElementID
  let selection  : Binding<Selection>?
  let value      : Selection.SelectionValue?
  let isSelected : Bool
  let content    : HTMLTreeNode

  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return SUIListItemNode(elementID  : elementID,
                           selection  : selection,
                           value      : value,
                           isSelected : isSelected,
                           content    : newContent)
  }
  
  func takeValue(_ webID: [String], value: String,
                 in context: TreeStateContext) throws
  {
    // Note: The HTMLWrappingNode checks for our own elementID first,
    //       which is not what we want here, because _our_ ID is the real
    //       ID *plus* our "|" marker.
    try content.takeValue(webID, value: value, in: context)
  }
  func invoke(_ webID: [String], in context: TreeStateContext) throws {
    // Note: The HTMLWrappingNode checks for our own elementID first,
    //       which is not what we want here, because _our_ ID is the real
    //       ID *plus* our "|" marker.

    if elementID.isContainedInWebID(webID), elementID.count == webID.count {
      assert(selection != nil, "click event on element w/o selection")
      assert(value     != nil, "click event on element w/o value")
      if let value = value, let selection = selection {
        selection.wrappedValue.toggle(value)
      }
      return
    }

    try content.invoke(webID, in: context)
  }

  var onClickValue: String { return "SwiftUI.click(this,event);return false" }

  func generateHTML(into html: inout String) {
    html += "<div class=\"item"
    if selection != nil && value != nil { html += " selectable" }
    if isSelected { html += " active" }
    html += "\""
    html.appendAttribute("id", elementID.webID)
    
    if selection != nil && value != nil {
      html.appendAttribute("onclick", onClickValue)
    }
    
    html += ">"
    defer { html += "</div>" }
    
    content.generateHTML(into: &html)
  }
  
  func generateChanges(from oldNode: HTMLTreeNode,
                       into changeset: inout [HTMLChange],
                       in context: TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.isSelected != isSelected {
      changeset.append(
        .init(elementID.webID, toggleClass: "active", isEnabled: isSelected)
      )
    }

    // TBD: diff on value/selection
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<ListItem \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<ListItem/>")
  }

}
