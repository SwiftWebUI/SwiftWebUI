//
//  HTMLWrappingNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

/// A node with exactly one child.
public protocol HTMLWrappingNode: HTMLTreeNode {
  var content : HTMLTreeNode { get }
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self
}

extension HTMLWrappingNode {

  var containsSpacer : Bool { return content.containsSpacer }

  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        return nodeByApplyingNewContent(content.rewrite(using: rewriter))
    }
  }
  
  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.isContainedInWebID(webID) else { return }
    try content.takeValue(webID, value: value, in: context)
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    try content.invoke(webID, in: context)
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  func generateHTML(into html: inout String) {
    content.generateHTML(into: &html)
  }

  public var children : [ HTMLTreeNode ] { [ content ] }
  func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<\(self)>")
    for c in children {
      c.dump(nesting: nesting + 1)
    }
    print("\(indent)</\(self)>")
  }

}
