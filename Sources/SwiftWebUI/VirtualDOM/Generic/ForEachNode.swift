//
//  ForEachNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct ForEachNode<ID: Hashable> : HTMLTreeNode {
  
  let elementID : ElementID
  let ids       : [ ( id: ID, webID: String )   ]
  let children  : [ HTMLTreeNode ] // TODO: build on demand

  var containsSpacer : Bool {
    return children.firstIndex(where: { $0.containsSpacer }) != nil
  }
  var isContentNode : Bool { return false }

  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        return ForEachNode(elementID: elementID, ids: ids,
                           children: children.map {$0.rewrite(using: rewriter)})
    }
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    
    let componentID = webID[elementID.count]
      // FIXME: hashmap?
    
    guard let idx = ids.firstIndex(where: { $0.webID == componentID }) else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    
    try children[idx].takeValue(webID, value: value, in: context)
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    
    let componentID = webID[elementID.count]
      // FIXME: hashmap?
    
    guard let idx = ids.firstIndex(where: { $0.webID == componentID }) else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    
    try children[idx].invoke(webID, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<ForEach: #\(children.count)>")
    for content in children {
      content.dump(nesting: nesting + 1)
    }
    print("\(indent)<ForEach/>")
  }
  
  func generateHTML(into html: inout String) {
    for content in children {
      content.generateHTML(into: &html)
    }
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }

    if ids.count == oldNode.ids.count { // optimize the "same" case
      let sameIDs : Bool = {
        for i in 0..<ids.count {
          guard ids[i] == oldNode.ids[i] else { return false }
        }
        return true
      }()
      if sameIDs {
        assert(children.count == oldNode.children.count)
        for i in 0..<children.count {
          children[i].generateChanges(from: oldNode.children[i],
                                      into: &changeset, in: context)
        }
        return
      }
    }
    
    // TODO: Optimize to hell. Special cases like count==count, add one etc.
    let oldIDs     = Set(oldNode.ids.map { $0.id } )
    let newIDs     = Set(        ids.map { $0.id } )
    let sameIDs    = oldIDs.intersection(newIDs)
    
    for deletedID in oldIDs.subtracting(newIDs) {
      let eid = elementID.appendingElementIDComponent(deletedID)
      context.nodeGotDeleted(eid)
      changeset.append(.deleteElement(webID: eid.webID))
    }
    
    if !sameIDs.isEmpty {
      let oldSame = oldNode.ids.map { $0.id }.filter({sameIDs.contains($0)})
      let newSame =         ids.map { $0.id }.filter({sameIDs.contains($0)})
      if oldSame != newSame {
        // FIXME: better imp, e.g. consider orders which stay the same
        for i in 0..<ids.count {
          let eid = elementID.appendingElementIDComponent(ids[i].0).webID
          let afterEID = i > 0
              ? elementID.appendingElementIDComponent(ids[i - 1].0).webID
              : nil
          changeset.append(.order(webID: eid, after: afterEID))
        }
      }
    }
    
    for newID in newIDs.subtracting(oldIDs) {
      guard let idx = ids.firstIndex(where: { $0.id == newID }) else {
        assertionFailure("missing ID ... ")
        continue
      }
      
      var html = ""
      children[idx].generateHTML(into: &html)
      
      let eid = elementID.appendingElementIDComponent(newID)
      if idx > ids.startIndex {
        let predIdx = ids.index(before: idx)
        let predID  = elementID.appendingElementIDComponent(ids[predIdx].1)
        changeset.append(
          .insertElementWithHTML(webID: eid.webID, after: predID.webID,
                                 html: html)
        )
      }
      else {
        changeset.append(
          .insertElementWithHTML(webID: eid.webID, after: nil, html: html)
        )
      }
    }
  }
}
