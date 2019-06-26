//
//  HTMLFrameNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 25.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLFrameNode: HTMLWrappingNode {
  
  let elementID : ElementID
  let value     : FrameLayout.Value
  let content   : HTMLTreeNode

  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLFrameNode(elementID: elementID, value: value,
                         content: newContent)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Frame: \(value)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</Frame>")
  }
  
  var styles : CSSStyles {
    var styles = CSSStyles()
    if let v = value.width  { styles[.width]  = v }
    if let v = value.height { styles[.height] = v }

    styles[.flexDirection]  = "row"
    styles[.alignItems]     = value.alignment.vertical
    styles[.justifyContent] = value.alignment.horizontal
    return styles
  }

  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-frame\""
    html.appendAttribute("id",    elementID.webID)
    html.appendAttribute("style", styles.cssStringValue)
    html += ">"
    defer { html += "</div>" }

    content.generateHTML(into: &html)
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.value != value {
      changeset.append(.setAttribute(webID: elementID.webID,
                                     attribute: "style",
                                     value: styles.cssStringValue ?? ""))
    }
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
}
