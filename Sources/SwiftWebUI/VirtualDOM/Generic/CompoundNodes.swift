//
//  CompoundNodes.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// TODO: Use Array for all to get diffing

public protocol HTMLTupleNode : HTMLTreeNode {}
public extension HTMLTupleNode {
  var isContentNode : Bool { return false } // TBD: is this actually true??
}

struct CompoundNode2: HTMLTupleNode {
  
  let elementID : ElementID
  let t1        : HTMLTreeNode
  let t2        : HTMLTreeNode

  var containsSpacer : Bool { return t1.containsSpacer || t2.containsSpacer }
  var isContentNode  : Bool { return false }

  public var children : [ HTMLTreeNode ] { [ t1, t2 ] }

  init(elementID: ElementID, _ t1: HTMLTreeNode, _ t2: HTMLTreeNode) {
    self.elementID = elementID
    self.t1 = t1
    self.t2 = t2
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.takeValue(webID, value: value, in: context)
      case "1": try t2.takeValue(webID, value: value, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    // Those could be smarter and support other tuple types, but then those
    // should never change, right?
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
  }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple2: \(elementID)>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

struct CompoundNode3: HTMLTupleNode {
  
  let elementID : ElementID
  let t1        : HTMLTreeNode
  let t2        : HTMLTreeNode
  let t3        : HTMLTreeNode

  public var children : [ HTMLTreeNode ] { [ t1, t2, t3 ] }

  var containsSpacer : Bool {
    return t1.containsSpacer || t2.containsSpacer || t3.containsSpacer
  }
  var isContentNode  : Bool { return false }

  init(elementID: ElementID,
       _ t1: HTMLTreeNode, _ t2: HTMLTreeNode, _ t3: HTMLTreeNode)
  {
    self.elementID = elementID
    self.t1 = t1
    self.t2 = t2
    self.t3 = t3
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.takeValue(webID, value: value, in: context)
      case "1": try t2.takeValue(webID, value: value, in: context)
      case "2": try t3.takeValue(webID, value: value, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      case "2": try t3.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
    t3.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
    t3.generateChanges(from: oldNode.t3, into: &changeset, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple3: \(elementID)>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    t3.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

struct CompoundNode4: HTMLTupleNode {
  
  let elementID : ElementID
  let t1        : HTMLTreeNode
  let t2        : HTMLTreeNode
  let t3        : HTMLTreeNode
  let t4        : HTMLTreeNode

  public var children : [ HTMLTreeNode ] { [ t1, t2, t3, t4 ] }
  
  var containsSpacer : Bool {
    return t1.containsSpacer || t2.containsSpacer || t3.containsSpacer
        || t4.containsSpacer
  }
  var isContentNode  : Bool { return false }

  init(elementID: ElementID,
       _ t1: HTMLTreeNode, _ t2: HTMLTreeNode, _ t3: HTMLTreeNode,
       _ t4: HTMLTreeNode)
  {
    self.elementID = elementID
    self.t1 = t1; self.t2 = t2; self.t3 = t3; self.t4 = t4
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.takeValue(webID, value: value, in: context)
      case "1": try t2.takeValue(webID, value: value, in: context)
      case "2": try t3.takeValue(webID, value: value, in: context)
      case "3": try t4.takeValue(webID, value: value, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      case "2": try t3.invoke(webID, in: context)
      case "3": try t4.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
    t3.generateHTML(into: &html)
    t4.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
    t3.generateChanges(from: oldNode.t3, into: &changeset, in: context)
    t4.generateChanges(from: oldNode.t4, into: &changeset, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple4>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    t3.dump(nesting: nesting + 1)
    t4.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

struct CompoundNode5: HTMLTupleNode {
  let elementID : ElementID
  let t1: HTMLTreeNode, t2: HTMLTreeNode, t3: HTMLTreeNode
  let t4: HTMLTreeNode, t5: HTMLTreeNode

  public var children : [ HTMLTreeNode ] { [ t1, t2, t3, t4, t5 ] }
  
  var containsSpacer : Bool {
    return t1.containsSpacer || t2.containsSpacer || t3.containsSpacer
        || t4.containsSpacer || t5.containsSpacer
  }
  var isContentNode  : Bool { return false }

  init(elementID: ElementID,
       _ t1: HTMLTreeNode, _ t2: HTMLTreeNode, _ t3: HTMLTreeNode,
       _ t4: HTMLTreeNode, _ t5: HTMLTreeNode)
  {
    self.elementID = elementID
    self.t1 = t1; self.t2 = t2; self.t3 = t3; self.t4 = t4; self.t5 = t5
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.takeValue(webID, value: value, in: context)
      case "1": try t2.takeValue(webID, value: value, in: context)
      case "2": try t3.takeValue(webID, value: value, in: context)
      case "3": try t4.takeValue(webID, value: value, in: context)
      case "4": try t5.takeValue(webID, value: value, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      case "2": try t3.invoke(webID, in: context)
      case "3": try t4.invoke(webID, in: context)
      case "4": try t5.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
    t3.generateHTML(into: &html)
    t4.generateHTML(into: &html)
    t5.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
    t3.generateChanges(from: oldNode.t3, into: &changeset, in: context)
    t4.generateChanges(from: oldNode.t4, into: &changeset, in: context)
    t5.generateChanges(from: oldNode.t5, into: &changeset, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple5>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    t3.dump(nesting: nesting + 1)
    t4.dump(nesting: nesting + 1)
    t5.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

struct CompoundNode6: HTMLTupleNode {
  let elementID : ElementID
  let t1: HTMLTreeNode, t2: HTMLTreeNode, t3: HTMLTreeNode
  let t4: HTMLTreeNode, t5: HTMLTreeNode, t6: HTMLTreeNode

  public var children : [ HTMLTreeNode ] { [ t1, t2, t3, t4, t5, t6 ] }
  
  var containsSpacer : Bool {
    return t1.containsSpacer || t2.containsSpacer || t3.containsSpacer
        || t4.containsSpacer || t5.containsSpacer || t6.containsSpacer
  }
  var isContentNode  : Bool { return false }

  init(elementID: ElementID,
       _ t1: HTMLTreeNode, _ t2: HTMLTreeNode, _ t3: HTMLTreeNode,
       _ t4: HTMLTreeNode, _ t5: HTMLTreeNode, _ t6: HTMLTreeNode)
  {
    self.elementID = elementID
    self.t1 = t1; self.t2 = t2; self.t3 = t3; self.t4 = t4; self.t5 = t5
    self.t6 = t6
  }

  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      case "2": try t3.invoke(webID, in: context)
      case "3": try t4.invoke(webID, in: context)
      case "4": try t5.invoke(webID, in: context)
      case "5": try t6.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
    t3.generateHTML(into: &html)
    t4.generateHTML(into: &html)
    t5.generateHTML(into: &html)
    t6.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
    t3.generateChanges(from: oldNode.t3, into: &changeset, in: context)
    t4.generateChanges(from: oldNode.t4, into: &changeset, in: context)
    t5.generateChanges(from: oldNode.t5, into: &changeset, in: context)
    t6.generateChanges(from: oldNode.t6, into: &changeset, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple6>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    t3.dump(nesting: nesting + 1)
    t4.dump(nesting: nesting + 1)
    t5.dump(nesting: nesting + 1)
    t6.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

struct CompoundNode7: HTMLTupleNode {
  let elementID : ElementID
  let t1: HTMLTreeNode, t2: HTMLTreeNode, t3: HTMLTreeNode
  let t4: HTMLTreeNode, t5: HTMLTreeNode, t6: HTMLTreeNode
  let t7: HTMLTreeNode

  public var children : [ HTMLTreeNode ] { [ t1, t2, t3, t4, t5, t6, t7 ] }

  var containsSpacer : Bool {
    return t1.containsSpacer || t2.containsSpacer || t3.containsSpacer
        || t4.containsSpacer || t5.containsSpacer || t6.containsSpacer
        || t7.containsSpacer
  }
  var isContentNode  : Bool { return false }

  init(elementID: ElementID,
       _ t1: HTMLTreeNode, _ t2: HTMLTreeNode, _ t3: HTMLTreeNode,
       _ t4: HTMLTreeNode, _ t5: HTMLTreeNode, _ t6: HTMLTreeNode,
       _ t7: HTMLTreeNode)
  {
    self.elementID = elementID
    self.t1 = t1; self.t2 = t2; self.t3 = t3; self.t4 = t4; self.t5 = t5
    self.t6 = t6; self.t7 = t7
  }

  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      case "2": try t3.invoke(webID, in: context)
      case "3": try t4.invoke(webID, in: context)
      case "4": try t5.invoke(webID, in: context)
      case "5": try t6.invoke(webID, in: context)
      case "6": try t7.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
    t3.generateHTML(into: &html)
    t4.generateHTML(into: &html)
    t5.generateHTML(into: &html)
    t6.generateHTML(into: &html)
    t7.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
    t3.generateChanges(from: oldNode.t3, into: &changeset, in: context)
    t4.generateChanges(from: oldNode.t4, into: &changeset, in: context)
    t5.generateChanges(from: oldNode.t5, into: &changeset, in: context)
    t6.generateChanges(from: oldNode.t6, into: &changeset, in: context)
    t7.generateChanges(from: oldNode.t7, into: &changeset, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple7>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    t3.dump(nesting: nesting + 1)
    t4.dump(nesting: nesting + 1)
    t5.dump(nesting: nesting + 1)
    t6.dump(nesting: nesting + 1)
    t7.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

struct CompoundNode8: HTMLTupleNode {
  let elementID : ElementID
  let t1: HTMLTreeNode, t2: HTMLTreeNode, t3: HTMLTreeNode
  let t4: HTMLTreeNode, t5: HTMLTreeNode, t6: HTMLTreeNode
  let t7: HTMLTreeNode, t8: HTMLTreeNode

  public var children : [ HTMLTreeNode ] {
    [ t1, t2, t3, t4, t5, t6, t7, t8 ]
  }
  var containsSpacer : Bool {
    return t1.containsSpacer || t2.containsSpacer || t3.containsSpacer
        || t4.containsSpacer || t5.containsSpacer || t6.containsSpacer
        || t7.containsSpacer || t8.containsSpacer
  }
  var isContentNode  : Bool { return false }

  init(elementID: ElementID,
       _ t1: HTMLTreeNode, _ t2: HTMLTreeNode, _ t3: HTMLTreeNode,
       _ t4: HTMLTreeNode, _ t5: HTMLTreeNode, _ t6: HTMLTreeNode,
       _ t7: HTMLTreeNode, _ t8: HTMLTreeNode)
  {
    self.elementID = elementID
    self.t1 = t1; self.t2 = t2; self.t3 = t3; self.t4 = t4; self.t5 = t5
    self.t6 = t6; self.t7 = t7; self.t8 = t8
  }

  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      case "2": try t3.invoke(webID, in: context)
      case "3": try t4.invoke(webID, in: context)
      case "4": try t5.invoke(webID, in: context)
      case "5": try t6.invoke(webID, in: context)
      case "6": try t7.invoke(webID, in: context)
      case "7": try t8.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
    t3.generateHTML(into: &html)
    t4.generateHTML(into: &html)
    t5.generateHTML(into: &html)
    t6.generateHTML(into: &html)
    t7.generateHTML(into: &html)
    t8.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
    t3.generateChanges(from: oldNode.t3, into: &changeset, in: context)
    t4.generateChanges(from: oldNode.t4, into: &changeset, in: context)
    t5.generateChanges(from: oldNode.t5, into: &changeset, in: context)
    t6.generateChanges(from: oldNode.t6, into: &changeset, in: context)
    t7.generateChanges(from: oldNode.t7, into: &changeset, in: context)
    t8.generateChanges(from: oldNode.t8, into: &changeset, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple8>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    t3.dump(nesting: nesting + 1)
    t4.dump(nesting: nesting + 1)
    t5.dump(nesting: nesting + 1)
    t6.dump(nesting: nesting + 1)
    t7.dump(nesting: nesting + 1)
    t8.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

struct CompoundNode9: HTMLTupleNode {
  let elementID : ElementID
  let t1: HTMLTreeNode, t2: HTMLTreeNode, t3: HTMLTreeNode
  let t4: HTMLTreeNode, t5: HTMLTreeNode, t6: HTMLTreeNode
  let t7: HTMLTreeNode, t8: HTMLTreeNode, t9: HTMLTreeNode

  public var children : [ HTMLTreeNode ] {
    [ t1, t2, t3, t4, t5, t6, t7, t8, t9 ]
  }
  var containsSpacer : Bool {
    return t1.containsSpacer || t2.containsSpacer || t3.containsSpacer
        || t4.containsSpacer || t5.containsSpacer || t6.containsSpacer
        || t7.containsSpacer || t8.containsSpacer || t9.containsSpacer
  }
  var isContentNode  : Bool { return false }

  init(elementID: ElementID,
       _ t1: HTMLTreeNode, _ t2: HTMLTreeNode, _ t3: HTMLTreeNode,
       _ t4: HTMLTreeNode, _ t5: HTMLTreeNode, _ t6: HTMLTreeNode,
       _ t7: HTMLTreeNode, _ t8: HTMLTreeNode, _ t9: HTMLTreeNode)
  {
    self.elementID = elementID
    self.t1 = t1; self.t2 = t2; self.t3 = t3; self.t4 = t4; self.t5 = t5
    self.t6 = t6; self.t7 = t7; self.t8 = t8; self.t9 = t9
  }

  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    switch componentID {
      case "0": try t1.invoke(webID, in: context)
      case "1": try t2.invoke(webID, in: context)
      case "2": try t3.invoke(webID, in: context)
      case "3": try t4.invoke(webID, in: context)
      case "4": try t5.invoke(webID, in: context)
      case "5": try t6.invoke(webID, in: context)
      case "6": try t7.invoke(webID, in: context)
      case "7": try t8.invoke(webID, in: context)
      case "8": try t9.invoke(webID, in: context)
      default:
        throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
  }

  func generateHTML(into html: inout String) {
    t1.generateHTML(into: &html)
    t2.generateHTML(into: &html)
    t3.generateHTML(into: &html)
    t4.generateHTML(into: &html)
    t5.generateHTML(into: &html)
    t6.generateHTML(into: &html)
    t7.generateHTML(into: &html)
    t8.generateHTML(into: &html)
    t9.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    t1.generateChanges(from: oldNode.t1, into: &changeset, in: context)
    t2.generateChanges(from: oldNode.t2, into: &changeset, in: context)
    t3.generateChanges(from: oldNode.t3, into: &changeset, in: context)
    t4.generateChanges(from: oldNode.t4, into: &changeset, in: context)
    t5.generateChanges(from: oldNode.t5, into: &changeset, in: context)
    t6.generateChanges(from: oldNode.t6, into: &changeset, in: context)
    t7.generateChanges(from: oldNode.t7, into: &changeset, in: context)
    t8.generateChanges(from: oldNode.t8, into: &changeset, in: context)
    t9.generateChanges(from: oldNode.t9, into: &changeset, in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Tuple8>")
    t1.dump(nesting: nesting + 1)
    t2.dump(nesting: nesting + 1)
    t3.dump(nesting: nesting + 1)
    t4.dump(nesting: nesting + 1)
    t5.dump(nesting: nesting + 1)
    t6.dump(nesting: nesting + 1)
    t7.dump(nesting: nesting + 1)
    t8.dump(nesting: nesting + 1)
    t9.dump(nesting: nesting + 1)
    print("\(indent)</Tuple>")
  }
}

extension HTMLTupleNode {
  
  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    // FIXME: getting lazy. Instantiate proper efficient children
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        let newChildren = children.map { $0.rewrite(using: rewriter) }
        return CompoundNode.compoundNode(for: newChildren, with: elementID)
    }
  }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    // FIXME: getting lazy. Instantiate proper efficient children
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    guard let idx = Int(componentID) else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    let children = self.children
    guard idx >= 0 && idx < children.count else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    try children[idx].takeValue(webID, value: value, in: context)
  }
}

struct CompoundNode: HTMLTreeNode {
  
  let elementID : ElementID
  let children  : [ HTMLTreeNode ]
  
  static func compoundNode(for children: [ HTMLTreeNode ],
                           with elementID: ElementID) -> HTMLTreeNode
  {
    switch children.count {
      case 0:  return EmptyNode.shared
      case 1:  return children[0]
      // TBD: We could return tuple based children for some sizes
      default: return CompoundNode(elementID: elementID, children: children)
    }
  }
  
  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        let newChildren = children.map { $0.rewrite(using: rewriter) }
        return CompoundNode.compoundNode(for: newChildren, with: elementID)
    }
  }
  

  var containsSpacer : Bool {
    return children.firstIndex(where: { $0.containsSpacer }) != nil
  }
  var isContentNode  : Bool { return false }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    guard let idx = Int(componentID) else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    guard idx >= 0 && idx < children.count else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    try children[idx].takeValue(webID, value: value, in: context)
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    
    guard let componentID = Int(webID[elementID.count]),
          componentID >= 0 && componentID < children.count else
    {
      assertionFailure("unexpected webID: \(webID) \(self)")
      throw WebInvocationError
              .unexpectedComponentID(webID, webID[elementID.count])
    }
    try children[componentID].invoke(webID, in: context)
  }
  
  func generateHTML(into html: inout String) {
    for t in children {
      t.generateHTML(into: &html)
    }
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    for ( t, oldT ) in zip(children, oldNode.children) {
      t.generateChanges(from: oldT, into: &changeset, in: context)
    }
  }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Compound: #\(children.count)>")
    for t in children {
      t.dump(nesting: nesting + 1)
    }
    print("\(indent)</Compound>")
  }
}

struct TypedCompoundNode<Node: HTMLTreeNode>: HTMLTreeNode {
  
  let elementID     : ElementID
  let typedChildren : [ Node ]
  var children      : [ HTMLTreeNode ] { return typedChildren }
  
  init(elementID: ElementID, children: [ Node ]) {
    self.elementID     = elementID
    self.typedChildren = children
  }

  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        let newChildren = typedChildren.map { $0.rewrite(using: rewriter) }
        return CompoundNode.compoundNode(for: newChildren, with: elementID)
    }
  }

  var containsSpacer : Bool {
    return children.firstIndex(where: { $0.containsSpacer }) != nil
  }
  var isContentNode  : Bool { return false }

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    let componentID = webID[elementID.count]
    guard let idx = Int(componentID) else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    guard idx >= 0 && idx < children.count else {
      throw WebInvocationError.unexpectedComponentID(webID, componentID)
    }
    try children[idx].takeValue(webID, value: value, in: context)
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.count < webID.count       else { return }
    guard elementID.isContainedInWebID(webID) else { return }
    
    guard let componentID = Int(webID[elementID.count]),
          componentID >= 0 && componentID < children.count else
    {
      assertionFailure("unexpected webID: \(webID) \(self)")
      throw WebInvocationError
              .unexpectedComponentID(webID, webID[elementID.count])
    }
    try children[componentID].invoke(webID, in: context)
  }
  
  func generateHTML(into html: inout String) {
    for t in children {
      t.generateHTML(into: &html)
    }
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    for ( t, oldT ) in zip(children, oldNode.children) {
      t.generateChanges(from: oldT, into: &changeset, in: context)
    }
  }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Compound: #\(children.count)>")
    for t in children {
      t.dump(nesting: nesting + 1)
    }
    print("\(indent)</Compound>")
  }
}
