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
  
  /// An empty `ForEach` renders a placeholder element, so that rows which
  /// get added later have a sibling to anchor on (like `EmptyNode`).
  private var isEmpty : Bool { return children.isEmpty }
  
  func generateHTML(into html: inout String) {
    if isEmpty {
      html += "<div class=\"swiftui-empty\""
      html.appendAttribute("id", elementID.webID)
      html += "></div>"
      return
    }
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
    
    // Note: The DOM element of a child is not necessarily the one with the
    //       child's ID, e.g. `List` wraps rows into an item element. The
    //       `elementID` of the child node is the outermost element.
    //
    // Inserts are emitted before deletes, so that a row of the old list can
    // serve as the anchor even if it goes away. If the old list was empty,
    // the placeholder is the anchor.
    
    if isEmpty && !oldNode.isEmpty { // all rows go away, placeholder comes in
      var html = ""
      generateHTML(into: &html)
      changeset.append(
        .insertElementWithHTML(webID: elementID.webID,
                               at: .before(oldNode.children[0].elementID.webID),
                               html: html)
      )
    }
    
    // Walk the new elements in order, so that a predecessor which is new
    // itself has been inserted by the time it is used as the anchor.
    for idx in ids.indices where !oldIDs.contains(ids[idx].id) {
      var html = ""
      children[idx].generateHTML(into: &html)
      
      let webID    = children[idx].elementID.webID
      let position : HTMLChange.InsertPosition
      if idx > ids.startIndex {
        position = .after(children[idx - 1].elementID.webID)
      }
      else if let succIdx = ids.indices.dropFirst().first(where: {
                              sameIDs.contains(ids[$0].id) })
      {
        position = .before(children[succIdx].elementID.webID)
      }
      else if let firstOld = oldNode.children.first { // all old rows go away
        position = .before(firstOld.elementID.webID)
      }
      else { // the old list was empty, anchor on the placeholder
        position = .before(elementID.webID)
      }
      changeset.append(
        .insertElementWithHTML(webID: webID, at: position, html: html)
      )
    }
    
    if !isEmpty && oldNode.isEmpty { // placeholder goes away
      changeset.append(.deleteElement(webID: elementID.webID))
    }
    
    for idx in oldNode.ids.indices where !newIDs.contains(oldNode.ids[idx].id) {
      let eid = elementID.appendingElementIDComponent(oldNode.ids[idx].id)
      context.nodeGotDeleted(eid)
      changeset.append(.deleteElement(webID: oldNode.children[idx].elementID.webID))
    }
    
    if !sameIDs.isEmpty {
      let oldSame = oldNode.ids.map { $0.id }.filter({sameIDs.contains($0)})
      let newSame =         ids.map { $0.id }.filter({sameIDs.contains($0)})
      if oldSame != newSame {
        // FIXME: better imp, e.g. consider orders which stay the same
        for i in 0..<ids.count {
          let afterEID = i > 0 ? children[i - 1].elementID.webID : nil
          changeset.append(.order(webID: children[i].elementID.webID,
                                  after: afterEID))
        }
      }
    }
  }
}
