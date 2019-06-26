//
//  TupleTreeBuilder.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

extension HTMLTreeBuilder {
  
  func buildTree<T1: View, T2: View>
         (for view: TupleView2<T1, T2>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode2(elementID: context.currentElementID, t1, t2)
  }
  func buildTree<T1: View, T2: View, T3: View>
         (for view: TupleView3<T1, T2, T3>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.incrementLastElementIDComponent()
    let t3 = buildTree(for: view.value3, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode3(elementID: context.currentElementID, t1, t2, t3)
  }
  func buildTree<T1: View, T2: View, T3: View, T4: View>
         (for view: TupleView4<T1, T2, T3, T4>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.incrementLastElementIDComponent()
    let t3 = buildTree(for: view.value3, in: context)
    context.incrementLastElementIDComponent()
    let t4 = buildTree(for: view.value4, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode4(elementID: context.currentElementID,
                         t1, t2, t3, t4)
  }
  func buildTree<T1: View, T2: View, T3: View, T4: View, T5: View>
         (for view: TupleView5<T1, T2, T3, T4, T5>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.incrementLastElementIDComponent()
    let t3 = buildTree(for: view.value3, in: context)
    context.incrementLastElementIDComponent()
    let t4 = buildTree(for: view.value4, in: context)
    context.incrementLastElementIDComponent()
    let t5 = buildTree(for: view.value5, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode5(elementID: context.currentElementID,
                         t1, t2, t3, t4, t5)
  }
  func buildTree<T1: View, T2: View, T3: View, T4: View, T5: View,
                 T6: View>
         (for view: TupleView6<T1, T2, T3, T4, T5, T6>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.incrementLastElementIDComponent()
    let t3 = buildTree(for: view.value3, in: context)
    context.incrementLastElementIDComponent()
    let t4 = buildTree(for: view.value4, in: context)
    context.incrementLastElementIDComponent()
    let t5 = buildTree(for: view.value5, in: context)
    context.incrementLastElementIDComponent()
    let t6 = buildTree(for: view.value6, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode6(elementID: context.currentElementID,
                         t1, t2, t3, t4, t5, t6)
  }
  func buildTree<T1: View, T2: View, T3: View, T4: View, T5: View,
                 T6: View, T7: View>
         (for view: TupleView7<T1, T2, T3, T4, T5, T6, T7>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.incrementLastElementIDComponent()
    let t3 = buildTree(for: view.value3, in: context)
    context.incrementLastElementIDComponent()
    let t4 = buildTree(for: view.value4, in: context)
    context.incrementLastElementIDComponent()
    let t5 = buildTree(for: view.value5, in: context)
    context.incrementLastElementIDComponent()
    let t6 = buildTree(for: view.value6, in: context)
    context.incrementLastElementIDComponent()
    let t7 = buildTree(for: view.value7, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode7(elementID: context.currentElementID,
                         t1, t2, t3, t4, t5, t6, t7)
  }
  func buildTree<T1: View, T2: View, T3: View, T4: View, T5: View,
                 T6: View, T7: View, T8: View>
         (for view: TupleView8<T1, T2, T3, T4, T5, T6, T7, T8>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.incrementLastElementIDComponent()
    let t3 = buildTree(for: view.value3, in: context)
    context.incrementLastElementIDComponent()
    let t4 = buildTree(for: view.value4, in: context)
    context.incrementLastElementIDComponent()
    let t5 = buildTree(for: view.value5, in: context)
    context.incrementLastElementIDComponent()
    let t6 = buildTree(for: view.value6, in: context)
    context.incrementLastElementIDComponent()
    let t7 = buildTree(for: view.value7, in: context)
    context.incrementLastElementIDComponent()
    let t8 = buildTree(for: view.value8, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode8(elementID: context.currentElementID,
                         t1, t2, t3, t4, t5, t6, t7, t8)
  }
  
  func buildTree<T1: View, T2: View, T3: View, T4: View, T5: View,
                 T6: View, T7: View, T8: View, T9: View>
         (for view: TupleView9<T1, T2, T3, T4, T5, T6, T7, T8, T9>,
          in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendZeroElementIDComponent()
    let t1 = buildTree(for: view.value1, in: context)
    context.incrementLastElementIDComponent()
    let t2 = buildTree(for: view.value2, in: context)
    context.incrementLastElementIDComponent()
    let t3 = buildTree(for: view.value3, in: context)
    context.incrementLastElementIDComponent()
    let t4 = buildTree(for: view.value4, in: context)
    context.incrementLastElementIDComponent()
    let t5 = buildTree(for: view.value5, in: context)
    context.incrementLastElementIDComponent()
    let t6 = buildTree(for: view.value6, in: context)
    context.incrementLastElementIDComponent()
    let t7 = buildTree(for: view.value7, in: context)
    context.incrementLastElementIDComponent()
    let t8 = buildTree(for: view.value8, in: context)
    context.incrementLastElementIDComponent()
    let t9 = buildTree(for: view.value9, in: context)
    context.deleteLastElementIDComponent()
    return CompoundNode9(elementID: context.currentElementID,
                         t1, t2, t3, t4, t5, t6, t7, t8, t9)
  }
}
