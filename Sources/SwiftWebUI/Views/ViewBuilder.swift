//
//  ViewBuilder.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@resultBuilder public struct ViewBuilder {

  public static func buildBlock() -> EmptyView {
    return EmptyView()
  }
  
  public static func buildBlock<Content: View>(_ content: Content) -> Content {
    return content
  }
}

public extension ViewBuilder {
  
  static func buildIf<V: View>(_ content: V)  -> V  { return content }
  //static func buildIf<V: View>(_ content: V?) -> V? { return content }
    // This one still doesn't work!
  
  static func buildEither<T: View, F: View>(first: T)
              -> ConditionalContent<T, F>
  {
    return ConditionalContent(first: first)
  }
  static func buildEither<T: View, F: View>(second: F)
              -> ConditionalContent<T, F>
  {
    return ConditionalContent(second: second)
  }
}

public extension ViewBuilder { // Tuples
  
  #if false // can't get those to work yet (FIXME, should work now)
  static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1)
              -> TupleView<(C0, C1)>
  {
    return TupleView(( c0, c1 ))
  }
  #else
  static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1)
                     -> TupleView2<C0, C1>
  {
    return TupleView2(c0, c1)
  }
  #endif
  static func buildBlock<C0: View, C1: View, C2: View>
                       (_ c0: C0, _ c1: C1, _ c2: C2)
                     -> TupleView3<C0, C1, C2>
  {
    return TupleView3(c0, c1, c2)
  }
  static func buildBlock<C0: View, C1: View, C2: View, C3: View>
                       (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3)
                     -> TupleView4<C0, C1, C2, C3>
  {
    return TupleView4(c0, c1, c2, c3)
  }
  static func buildBlock<C0: View, C1: View, C2: View, C3: View,
                                C4: View>
                       (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4)
                     -> TupleView5<C0, C1, C2, C3, C4>
  {
    return TupleView5(c0, c1, c2, c3, c4)
  }
  static func buildBlock<C0: View, C1: View, C2: View, C3: View,
                                C4: View, C5: View>
                       (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4,
                        _ c5: C5)
                     -> TupleView6<C0, C1, C2, C3, C4, C5>
  {
    return TupleView6(c0, c1, c2, c3, c4, c5)
  }
  static func buildBlock<C0: View, C1: View, C2: View, C3: View,
                                C4: View, C5: View, C6: View>
                       (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4,
                        _ c5: C5, _ c6: C6)
                     -> TupleView7<C0, C1, C2, C3, C4, C5, C6>
  {
    return TupleView7(c0, c1, c2, c3, c4, c5, c6)
  }
  static func buildBlock<C0: View, C1: View, C2: View, C3: View,
                                C4: View, C5: View, C6: View, C7: View>
                       (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4,
                        _ c5: C5, _ c6: C6, _ c7: C7 )
                     -> TupleView8<C0, C1, C2, C3, C4, C5, C6, C7>
  {
    return TupleView8(c0, c1, c2, c3, c4, c5, c6, c7)
  }
  static func buildBlock<C0: View, C1: View, C2: View, C3: View,
                                C4: View, C5: View, C6: View, C7: View,
                                C8: View>
                       (_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4,
                        _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8)
                     -> TupleView9<C0, C1, C2, C3, C4, C5, C6, C7, C8>
  {
    return TupleView9(c0, c1, c2, c3, c4, c5, c6, c7, c8)
  }

}
