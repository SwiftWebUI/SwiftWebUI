//
//  TreeBuilder.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 06.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

enum WebInvocationError: Swift.Error {
  case unexpectedComponentID([ String ], String)
  case inactiveElement([String])
}

public enum RewriteAction {
  case recurse
  case replaceAndReturn(newNode: HTMLTreeNode)
}

public protocol HTMLTreeNode {
  // TBD: Figure out how to make this internal. It is public in part because
  //      the `View` protocol needs to have the `buildTree` method ATM.
  // TBD: Maybe this should be a associatedtype associated to the `View`
  //      protocol `associatedtype Resolved`, defaulting to DynamicElement.
  //      The only problem is that protocols do not conform to themselves,
  //      forbidding dynamic tree generation (e.g. static vs dynamic in
  //      the components themselves).
  // TBD: That we store the elementID frees us from having to regenerate them
  //      all the time when producing HTML in some branch. However, it makes
  //      rewriting them a hassle.
  
  var elementID : ElementID { get }
  
  
  // MARK: - Rewriting
  
  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  
  
  // MARK: - Layout Hacks
  
  var containsSpacer : Bool { get }
    // This is a hack to simulate the expansion behaviour when a view contains
    // a spacer. Need to find a better way to do this.
    // FIXME: Also the name, should be "wants100%"?
  
  var isContentNode : Bool { get }
    // Another hack to find the direct decendents which will generate some
    // form of block. This includes layout nodes.

  
  // MARK: - Reflection
  
  var children : [ HTMLTreeNode ] { get }
  
  func dump(nesting: Int)
  
  // MARK: - WOResponder
  
  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
    // FIXME: API naming
  
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws
    // FIXME: the API naming is not nice, but convenient ;-)
  
  func generateHTML(into html: inout String)

  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
}

extension HTMLTreeNode {
  var containsSpacer : Bool { return false }
  var isContentNode  : Bool { return true  }
}

extension HTMLTreeNode {
  
  func collectDirectContentNodes() -> [ HTMLTreeNode ] {
    // TBD: Just use traverse?!
    var list = [ HTMLTreeNode ]()
    list.reserveCapacity(10)
    collectDirectContentNodes(into: &list)
    return list
  }
  func collectDirectContentNodes(into list: inout [ HTMLTreeNode ]) {
    if isContentNode {
      list.append(self)
      return
    }
    
    for child in children { // yay, FIXME, put better API into protocol
      child.collectDirectContentNodes(into: &list)
    }
  }

}

extension HTMLTreeNode {
  
  func sameType(_ oldNode: HTMLTreeNode, _ changeset: inout [ HTMLChange ])
       -> Self?
  {
    if let oldNode = oldNode as? Self { return oldNode }

    #if DEBUG
      if oldNode.elementID != elementID {
        print("WARN: ID of node changed:",
              "\n  OLD:", oldNode.elementID.webID, type(of: oldNode),
              "\n  NEW:", elementID.webID, type(of: self))
        assert(oldNode.elementID == elementID)
      }
    #endif

    print("WARN: type of node changed:", elementID.webID,
          "\n  OLD:", type(of: oldNode),
          "\n  NEW:", type(of: self))
    var html = ""
    generateHTML(into: &html)
    let change = HTMLChange
                  .replaceElementWithHTML(webID: elementID.webID, html: html)
    changeset.append(change)
    return nil
  }
  
}

public extension HTMLTreeNode {
  func dump() { dump(nesting: 0) }
}
