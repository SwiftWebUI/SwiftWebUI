//
//  SUITabItemNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUITabItemNode: HTMLWrappingNode {
  
  let elementID  : ElementID
  let isSelected : Bool
  let contentID  : ElementID
  let content    : HTMLTreeNode

  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return SUITabItemNode(elementID: elementID, isSelected: isSelected,
                          contentID: contentID, content: newContent)
  }

  func invoke(_ webID: [String], in context: TreeStateContext) throws {
    // FIXME: detect clicks? Only necessary for non-JS
    try content.invoke(webID, in: context)
  }
  
  func generateHTML(into html: inout String) {
    let activeClass = isSelected ? " active" : ""
    html += "<a class=\"item\(activeClass)\""
    html.appendAttribute("id", elementID.webID)
    html.appendAttribute("data-tab", contentID.webID)
    
    // TODO: In here we need the data-tab attribute or some own custom
    //       click handler.
    // onclick="activateTabItem(this)"
    
    html.appendAttribute("onclick", "SwiftUI.tabClick(this,event);return false")
    
    html += ">"
    defer { html += "</a>" }
    
    content.generateHTML(into: &html)
  }
  
  func generateChanges(from oldNode: HTMLTreeNode,
                       into changeset: inout [HTMLChange],
                       in context: TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.isSelected != isSelected {
      changeset.append(
        isSelected
          ? .addClass   (webID: elementID.webID, class: "active")
          : .removeClass(webID: elementID.webID, class: "active")
      )
    }

    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<TabItem \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<TabItem/>")
  }
}
