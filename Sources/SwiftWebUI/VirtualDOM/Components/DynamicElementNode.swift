//
//  DynamicElementNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

class _DynamicElementNode: HTMLTreeNode {
  // aka WOComponent/WOComponentReference

  let elementID : ElementID
  var child     : HTMLTreeNode?
  
  fileprivate init(elementID: ElementID) {
    self.elementID = elementID
  }
  fileprivate init(elementID: ElementID, child: HTMLTreeNode) {
    self.elementID = elementID
    self.child     = child
  }

  var isContentNode : Bool { child?.isContentNode ?? true }

  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    fatalError("subclass responsibility: \(#function)")
  }
  func buildChild(in context: TreeStateContext) -> HTMLTreeNode {
    fatalError("subclass responsibility: \(#function)")
  }

  // MARK: - View Overrides
  
  var viewType: Any.Type {
    fatalError("subclass responsibility: \(#function)")
  }

  func execute<R>(in context: TreeStateContext, _ execute: () -> R) -> R {
    fatalError("subclass responsibility: \(#function)")
  }
  func execute<R>(in context: TreeStateContext,
                  _ execute: () throws -> R) throws -> R
  {
    fatalError("subclass responsibility: \(#function)")
  }
  
  // MARK: - WOResponder

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    guard elementID.isContainedInWebID(webID) else { return }
    try execute(in: context) {
      try child?.takeValue(webID, value: value, in: context)
    }
  }

  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    try execute(in: context) {
      try child?.invoke(webID, in: context)
    }
  }

  func generateHTML(into html: inout String) {
    child?.generateHTML(into: &html)
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    let oldChild1 = oldNode.child // hang on in case the objects are the same
    
    if context.processInvalidComponent(with: elementID) {
      if debugInvalidation {
        print("I: processing invalid component, rebuild child:", elementID)
      }
      self.child = buildChild(in: context)
    }
    
    guard let oldChild = oldChild1 else {
      assertionFailure("didn't have a child?")
      return
    }
    
    child?.generateChanges(from: oldChild, into: &changeset, in: context)
  }

  // MARK: - Tree Debugging Helpers
  
  public var children: [ HTMLTreeNode ] {
    guard let child = child else { return [] }
    return [ child ]
  }
  
  func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Component \(elementID.webID)>")
    child?.dump(nesting: nesting + 1)
    print("\(indent)</Component>")
  }
  
}

final class DynamicElementNode<V: View>: _DynamicElementNode,
                                         CustomStringConvertible
{
  // typed version
  
  var view : V
  
  init(elementID: ElementID, view: V) {
    self.view = view // Note: Here we make a copy of the view struct!
    super.init(elementID: elementID)
  }
  
  private init(elementID: ElementID, child: HTMLTreeNode, view: V) {
    self.view = view
    super.init(elementID: elementID, child: child)
  }
  
  override
  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse:
        guard let child = child else {
          assertionFailure("missing child")
          return self
        }
        return DynamicElementNode(elementID: elementID,
                                  child: child.rewrite(using: rewriter),
                                  view: view)
    }
  }

  override
  func execute<R>(in context: TreeStateContext, _ execute: () -> R) -> R {
    guard case .dynamic = view.lookupTypeInfo() else { return execute() }
    context.enterComponent(self)
    defer { context.leaveComponent(self) }
    return execute()
  }
  override
  func execute<R>(in context: TreeStateContext, _ execute: () throws -> R)
         throws -> R
  {
    // TBD: Use `rethrows`? Which I knew Swift ...
    guard case .dynamic = view.lookupTypeInfo() else { return try execute() }
    context.enterComponent(self)
    defer { context.leaveComponent(self) }
    return try execute()
  }

  override func buildChild(in context: TreeStateContext) -> HTMLTreeNode {
    return execute(in: context) {
      let oldID = context.pushElementID(elementID)
      defer { context.pushElementID(oldID) }

      context.appendContentElementIDComponent()

      let bodyTree = context.currentBuilder
                      ._buildContent(view.body, in: context)
      return bodyTree
    }
  }

  override var viewType: Any.Type {
    return V.self
  }

  // MARK: - Description
  
  var description: String {
    return "<Component: \(elementID) \(type(of: view))>"
  }
  
  override func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Component \(elementID.webID) \(viewType)>")
    child?.dump(nesting: nesting + 1)
    print("\(indent)</Component>")
  }
}
