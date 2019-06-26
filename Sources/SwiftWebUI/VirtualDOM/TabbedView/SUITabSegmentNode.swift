//
//  SUITabSegmentNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUITabSegmentNode: HTMLWrappingNode {
  
  let elementID  : ElementID
  let isSelected : Bool
  let content    : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return SUITabSegmentNode(elementID: elementID, isSelected: isSelected,
                             content: newContent)
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
    try content.invoke(webID, in: context)
  }

  func generateHTML(into html: inout String) {
    let activeClass = isSelected ? " active" : ""
    html += "<div class=\"ui bottom attached tab segment\(activeClass)\""
    html.appendAttribute("id",       elementID.webID)
    html.appendAttribute("data-tab", elementID.webID)
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
        .init(elementID.webID, toggle: "active", isEnabled: isSelected)
      )
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<TabContent \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<TabContent/>")
  }

}
