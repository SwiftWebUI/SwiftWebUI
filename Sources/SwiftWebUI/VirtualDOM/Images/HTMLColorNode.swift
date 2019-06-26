
//
//  ColorNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLColorNode: HTMLLeafNode {
  // Halp. How can I tell flexbox that I want this "div" to grow automagically
  // to take available space?
  // Right now we need to manually hack the size of this.
  
  var containsSpacer: Bool { return true }
  

  let elementID : ElementID
  let color     : Color
  
  var styles: CSSStyles {
    return [ .backgroundColor: color ]
  }

  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-color\""
    html.appendAttribute("id",    elementID.webID)
    html.appendAttribute("style", styles.cssStringValue)
    html += "></div>"
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    guard oldNode.color != color else { return }
    
    changeset.append(
      .setAttribute(webID: elementID.webID,
                    attribute: "style", value: styles.cssStringValue ?? "")
    )
  }
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Color: \(color)/>")
  }
}
