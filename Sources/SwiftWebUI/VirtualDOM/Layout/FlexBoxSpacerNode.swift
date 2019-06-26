//
//  FlexBoxSpacerNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct FlexBoxSpacerNode : HTMLLeafNode {
  
  let elementID : ElementID
  let minLength : Length?

  var containsSpacer : Bool { return true }

  var styles: CSSStyles? {
    guard let l = minLength else { return nil }
    // FIXME: consider orientation, only set the proper flow direction
    // => need the current orientation in the context
    return [
      .minHeight: l,
      .minWidth:  l
    ]
  }

  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-spacer\""
    html.appendAttribute("id", elementID.webID)
    if let s = styles?.cssStringValue { html.appendAttribute("style", s) }
    html += "></div>"
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    guard oldNode.minLength != minLength else { return }
    
    changeset.append(
      .setAttribute(webID: elementID.webID, attribute: "style",
                    value: styles?.cssStringValue ?? "")
    )
  }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    if let v = minLength { print("\(indent)<Spacer: \(v)>") }
    else                 { print("\(indent)<Spacer>") }
  }
}
