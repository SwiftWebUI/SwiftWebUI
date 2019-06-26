//
//  HTMLScrollView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLScrollNode : HTMLWrappingNode {
  
  let elementID   : ElementID
  let content     : HTMLTreeNode // type erased, hm
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLScrollNode(elementID: elementID, content: newContent)
  }
  
  var containsSpacer: Bool {
    // I guess, we behave like a spacer and grab all available width?
    return false 
  }
  
  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-scroll\""
    html.appendAttribute("id", elementID.webID)
    html += ">"
    defer { html += "</div>" }
    
    content.generateHTML(into: &html)
  }
  
  // MARK: - Debug

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Scroller>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</Scroller>")
  }
}
