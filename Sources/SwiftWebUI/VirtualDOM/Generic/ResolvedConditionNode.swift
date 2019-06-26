//
//  ResolvedConditionNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct ResolvedConditionNode: HTMLWrappingNode {

  let elementID : ElementID
  let flag      : Bool
  let content   : HTMLTreeNode

  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return ResolvedConditionNode(elementID: elementID, flag, newContent)
  }
  var isContentNode : Bool { return false }
  
  init(elementID: ElementID, _ flag: Bool, _ content: HTMLTreeNode) {
    self.elementID = elementID
    self.flag      = flag
    self.content   = content
  }

  #if false
    // This is wrong, we need to replace the tree and keep the ID stable!
  
  // TODO: appendValue
  
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    
    let componentID = webID[elementID.count]
    switch componentID {
      case "1": if flag  { try content.invoke(webID, in: context) }
      case "0": if !flag { try content.invoke(webID, in: context) }
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.flag == flag {
      return content.generateChanges(from: oldNode.content, into: &changeset,
                                     in: context)
    }
    
    // TBD: This should still work, it can (validly) run into the `sameType`
    //      mismatch.
    return content.generateChanges(from: oldNode.content, into: &changeset,
                                   in: context)
  }
  #endif
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<\(flag ? "If" : "IfNot")>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<\(flag ? "If" : "IfNot")/>")
  }
}
