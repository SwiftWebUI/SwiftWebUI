//
//  SUITabContainerNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUITabContainerNode<SelectionValue: Hashable>: HTMLTreeNode {
  
  let elementID : ElementID
  let selection : SelectionValue
  let tabItems  : HTMLTreeNode
  let content   : HTMLTreeNode

  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        return SUITabContainerNode(elementID : elementID, selection: selection,
                                   tabItems  : tabItems.rewrite(using: rewriter),
                                   content   : content .rewrite(using: rewriter))
    }
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.isContainedInWebID(webID) else { return }
    
    if elementID.count == webID.count {
      // FIXME: handle selection event!!!
      print("process value?!", self)
    }
    
    try tabItems.takeValue(webID, value: value, in: context)
    try content .takeValue(webID, value: value, in: context)
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    
    if elementID.count == webID.count {
      // FIXME: handle selection event!!!
      print("process selection event", self)
    }
    
    try tabItems.invoke(webID, in: context)
    try content .invoke(webID, in: context)
  }
  
  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-tabbedview\""
    html.appendAttribute("id", elementID.webID)
    html += ">"
    defer { html += "</div>" }
    
    do {
      html += "<div class=\"ui top attached tabular menu\">"
      defer { html += "</div>" }
      tabItems.generateHTML(into: &html)
    }
    
    content.generateHTML(into: &html)
  }
  
  func generateChanges(from oldNode: HTMLTreeNode,
                       into changeset: inout [HTMLChange],
                       in context: TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    // TBD: selection changes? Can we even get them? Binding? Always send the
    //      freshest?
    
    tabItems.generateChanges(from: oldNode.tabItems, into: &changeset,
                             in: context)
    content .generateChanges(from: oldNode.content, into: &changeset,
                             in: context)
  }
  
  // MARK: - Debugging
  
  var children  : [ HTMLTreeNode ] { [ content ] }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<TabbedView \(elementID.webID)>")
    tabItems.dump(nesting: nesting + 1)
    content.dump(nesting: nesting + 1)
    print("\(indent)<TabbedView/>")
  }

}
