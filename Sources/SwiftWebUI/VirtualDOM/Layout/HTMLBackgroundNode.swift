//
//  HTMLBackgroundNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 25.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLBackgroundNode: HTMLWrappingNode {
  
  let elementID : ElementID
  let value     : BackgroundModifier.Value
  let content   : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLBackgroundNode(elementID: elementID, value: value,
                              content: newContent)
  }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    var info = ""
    if let v = value.color        { info += " color=\(v)"  }
    if let v = value.cornerRadius { info += " radius=\(v)" }
    print("\(indent)<Background: \(elementID) \(value)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</Background>")
  }
  
  var styles: CSSStyles? {
    switch ( value.color, value.cornerRadius ) {
      case ( .some(let color), .some(let cornerRadius) ):
        return [ .backgroundColor: color, .borderRadius: cornerRadius ]
      case ( .some(let color), .none ):
        return [ .backgroundColor: color ]
      case ( .none, .some(let cornerRadius) ):
        return [ .borderRadius: cornerRadius ]
      case ( .none, .none ):
        return nil
    }
  }

  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-bg\""
    html.appendAttribute("id", elementID.webID)
    if let v = styles?.cssStringValue { html.appendAttribute("style", v) }
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
      print("TODO: implement:", #function, "in background:", Self.self)
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
}
