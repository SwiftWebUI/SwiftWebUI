//
//  TupleView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol TupleView: View {}

// TODO: Update: I think I know how to get it to work now.

// I just can't get them to work. Leave the tuple-based alone for now.
// Though this leads to lots and lots of repetition > Halp!
// Makes this whole thing a mess :-)

#if false

// it is quite likely that there is a way to constrain on the tuple in 5.1,
// but I don't know how
public struct TupleView<T> : View {
  
  public var value : T // TBD: why var?
  
  public init(_ value: T) {
    self.value = value
  }

  public typealias Body = Never

  // => this is pretty nice, but View:build conformance is preferred!
  func buildTree<T1: View, T2: View>(in context: TreeStateContext)
       -> HTMLTreeNode
       where T == ( T1, T2 )
  {
    let t1 = HTMLTreeBuilder.buildTree(for: value.0, in: context)
    let t2 = HTMLTreeBuilder.buildTree(for: value.1, in: context)

    return CompoundNode2(t1, t2)
  }
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return DummyNode()
  }

  final class CompoundNode2: HTMLTreeNode, WOResponder {
    
    let t1 : HTMLTreeNode
    let t2 : HTMLTreeNode

    init(_ t1: HTMLTreeNode, _ t2: HTMLTreeNode) {
      self.t1 = t1
      self.t2 = t2
    }
    
    func append(to response: WOResponse, in ctx: WOContext) throws {
      try t1.append(to: response, in: ctx)
      try t2.append(to: response, in: ctx)
    }
  }
}

#endif

/* doesn't work:
extension TupleView : HTMLTreeBuildingView
            where T == ( X, Y ), X: View, Y: View
{
  func buildTree(in context: TreeBuildingContext) -> HTMLTreeNode {
    return DummyNode()
  }
}
 */
  
public struct TupleView2<T1: View, T2: View>: TupleView {
  
  public let value1 : T1
  public let value2 : T2
  public init(_ value1: T1, _ value2: T2) {
    self.value1 = value1
    self.value2 = value2
  }
  public typealias Body = Never

}

public struct TupleView3<T1: View, T2: View, T3: View>: TupleView {
  public let value1 : T1
  public let value2 : T2
  public let value3 : T3
  public init(_ value1: T1, _ value2: T2, _ value3: T3) {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
  }
  public typealias Body = Never

}

public struct TupleView4<T1: View, T2: View, T3: View, T4: View>: TupleView {
  public let value1 : T1
  public let value2 : T2
  public let value3 : T3
  public let value4 : T4
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4) {
    self.value1 = value1
    self.value2 = value2
    self.value3 = value3
    self.value4 = value4
  }
  public typealias Body = Never

}

public struct TupleView5<T1: View, T2: View, T3: View, T4: View, T5: View>
              : TupleView
{
  public let value1: T1, value2: T2, value3: T3, value4: T4, value5: T5
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5)
  {
    self.value1 = value1; self.value2 = value2; self.value3 = value3
    self.value4 = value4; self.value5 = value5
  }
  public typealias Body = Never

}

public struct TupleView6<T1: View, T2: View, T3: View, T4: View, T5: View,
                         T6: View>
              : TupleView
{
  public let value1: T1, value2: T2, value3: T3, value4: T4, value5: T5
  public let value6: T6
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6)
  {
    self.value1 = value1; self.value2 = value2; self.value3 = value3
    self.value4 = value4; self.value5 = value5; self.value6 = value6
  }
  public typealias Body = Never

}

public struct TupleView7<T1: View, T2: View, T3: View, T4: View, T5: View,
                         T6: View, T7: View>
              : TupleView
{
  public let value1: T1, value2: T2, value3: T3, value4: T4, value5: T5
  public let value6: T6, value7: T7
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6, _ value7: T7)
  {
    self.value1 = value1; self.value2 = value2; self.value3 = value3
    self.value4 = value4; self.value5 = value5; self.value6 = value6
    self.value7 = value7
  }
  public typealias Body = Never

  
}

public struct TupleView8<T1: View, T2: View, T3: View, T4: View, T5: View,
                         T6: View, T7: View, T8: View>
              : TupleView
{
  public let value1: T1, value2: T2, value3: T3, value4: T4, value5: T5
  public let value6: T6, value7: T7, value8: T8
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6, _ value7: T7, _ value8: T8)
  {
    self.value1 = value1; self.value2 = value2; self.value3 = value3
    self.value4 = value4; self.value5 = value5; self.value6 = value6
    self.value7 = value7; self.value8 = value8
  }
  public typealias Body = Never

}

public struct TupleView9<T1: View, T2: View, T3: View, T4: View, T5: View,
                         T6: View, T7: View, T8: View, T9: View>
              : TupleView
{
  public let value1: T1, value2: T2, value3: T3, value4: T4, value5: T5
  public let value6: T6, value7: T7, value8: T8, value9: T9
  public init(_ value1: T1, _ value2: T2, _ value3: T3, _ value4: T4,
              _ value5: T5, _ value6: T6, _ value7: T7, _ value8: T8,
              _ value9: T9)
  {
    self.value1 = value1; self.value2 = value2; self.value3 = value3
    self.value4 = value4; self.value5 = value5; self.value6 = value6
    self.value7 = value7; self.value8 = value8; self.value9 = value9
  }
  public typealias Body = Never

}

extension TupleView2: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
extension TupleView3: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
extension TupleView4: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
extension TupleView5: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
extension TupleView6: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
extension TupleView7: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
extension TupleView8: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
extension TupleView9: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
