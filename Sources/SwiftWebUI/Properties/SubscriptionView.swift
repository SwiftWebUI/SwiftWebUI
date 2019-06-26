//
//  SubscriptionView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if canImport(Combine)
import Combine

public extension View {
  
  @available(*, unavailable) // enable once ready
  func onReceive<P>(_ publisher: P,
                    perform action: @escaping ( P.Output ) -> Void)
       -> SubscriptionView<P, Self>
      where P: Publisher, P.Failure == Never
  {
    return SubscriptionView(publisher: publisher, action: action, view: self)
  }

}

public struct SubscriptionView<P: Publisher, Content: View>: View
                where P.Failure == Never
{
  public typealias Body = Never
  
  let publisher : P
  let action    : ( P.Output ) -> Void
  let view      : Content
  
  init(publisher: P, action: @escaping ( P.Output ) -> Void, view: Content) {
    self.publisher = publisher
    self.action    = action
    self.view      = view
  }
}

extension HTMLTreeBuilder {
  
  func buildTree<P: Publisher, Content: View>(
         for view: SubscriptionView<P, Content>,
         in context: TreeStateContext) -> HTMLTreeNode
       where P.Failure == Never
  {
    context.appendContentElementIDComponent()
    let childTree = buildTree(for: view.view, in: context)
    context.deleteLastElementIDComponent()
    
    let tree = SubscriptionNode(elementID : context.currentElementID,
                                publisher : view.publisher,
                                action    : view.action,
                                content   : childTree)
    tree.resume()
    return tree
  }
}

final class SubscriptionNode<P: Publisher>: HTMLWrappingNode
              where P.Failure == Never
{
  let elementID    : ElementID
  let publisher    : P
  var subscription : AnyCancellable?
  let action       : ( P.Output ) -> Void
  let content      : HTMLTreeNode
  
  init(elementID: ElementID, publisher: P,
       subscription: AnyCancellable? = nil,
       action: @escaping ( P.Output ) -> Void,
       content: HTMLTreeNode)
  {
    self.elementID    = elementID
    self.publisher    = publisher
    self.subscription = subscription
    self.action       = action
    self.content      = content
  }
  
  func invoke(_ webID: [String], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    if elementID.count == webID.count {
      #if false // here we need the value ...
        action()
      #else
        print("CANT CALL ACTION YET")
      #endif
    }
    else {
      try content.invoke(webID, in: context)
    }
  }
  
  func resume() {
    subscription?.cancel()
    let v = publisher.sink { value in
      print("TODO: do something w/ published value:", value, self)
      // TODO:
      // So what we'd want to do here is enqueue an invocation request with
      // the value.
      // This should then call the action closure in the proper component
      // context.
    }
    self.subscription = AnyCancellable(v)
  }
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> SubscriptionNode
  {
    // TBD: Create a new subscription or reuse the old?
    return SubscriptionNode(elementID    : elementID,
                            publisher    : publisher,
                            subscription : subscription, // reuse old subscription
                            action       : action,
                            content      : newContent)
  }
}

#if DEBUG && false
fileprivate class MyStoreSubView: BindableObject {
  static let global = MyStoreSubView()
  var didChange = PassthroughSubject<Void, Never>()
  var i = 5 { didSet { didChange.send(()) } }
  
}
fileprivate struct MySubView : View {
  var body: some View {
    Text("Blub")
      .onReceive(MyStoreSubView.global.didChange) { print("blub") }
  }
}
#endif

#endif // canImport(Combine)
