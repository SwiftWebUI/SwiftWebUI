//
//  SUIListNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUIListNode<Selection: SelectionManager>: HTMLTreeNode {
  
  let elementID : ElementID
  let selection : Binding<Selection>?
  let content   : HTMLTreeNode

  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        return SUIListNode(elementID : elementID, selection: selection,
                           content   : content.rewrite(using: rewriter))
    }
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.isContainedInWebID(webID) else { return }
    assert(elementID.count != webID.count, "unexpected takeValue on list node")
    try content.takeValue(webID, value: value, in: context)
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    assert(elementID.count != webID.count, "unexpected invoke on list node")
    try content.invoke(webID, in: context)
  }
  
  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-list ui divided list"
    if selection != nil {
      html += " selectable"
    }
    html += "\""
    html.appendAttribute("id", elementID.webID)
    html += ">"
    defer { html += "</div>" }
    
    content.generateHTML(into: &html)
  }
  
  func generateChanges(from oldNode: HTMLTreeNode,
                       into changeset: inout [HTMLChange],
                       in context: TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  // MARK: - Debugging
  
  var children  : [ HTMLTreeNode ] { [ content ] }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<List \(elementID.webID)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<List/>")
  }

}
