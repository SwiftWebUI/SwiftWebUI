//
//  HTMLTreeBuilder.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 06.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if true
protocol TreeBuildingView {
  // FIXME: I'd like to drop this, but I'm not sure the compiler actually
  //        dispatches the way I want statically.
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode
  
}

#if false
  // The compiler does NOT expand this to the proper type specific buildTree,
  // but just fills in the protocol slot to this sole version which just takes
  // the TreeBuildingView again
extension TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}
#endif
#else
protocol TreeBuildingView: View {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode
  
}
#endif

class HTMLTreeBuilder {
  
  static let `default` = HTMLTreeBuilder()
  
  // FIXME: Drop static
  // FIXME: Drop TreeBuildingView, that might actually drop the ambiguouity
  //        and make the static dispatch work.
  
  func buildTree<V: View>(for view: V, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    #if true // this should not be required but currently fails in AnyView
    if let treeBuildingView : TreeBuildingView = view as? TreeBuildingView {
      #if false // ambiguous, somehow swiftc still considers the cast a View
        return buildTree(for: treeBuildingView, in: context)
      #else
        return treeBuildingView.buildTree(in: context)
      #endif
    }
    #endif

    guard case .dynamic = view.lookupTypeInfo() else {
      // Static
      return buildTree(for: view.body, in: context)
    }
    
    let node = DynamicElementNode(elementID: context.currentElementID,
                                  view: view)
    node.child = node.buildChild(in: context)
    return node
  }
  
  
  // MARK: - TreeBuildingViews (to be dropped)
  
  func buildTree<V: TreeBuildingView>(for view: V, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    return view.buildTree(in: context)
  }
  
  
  // MARK: - Compound Nodes
  
  func buildTree<Content: View>(for view: Group<Content>,
                                in context: TreeStateContext) -> HTMLTreeNode
  {
    let childTree = buildTree(for: view.content, in: context)
    return GroupNode(elementID: context.currentElementID, content: childTree)
  }

  // MARK: - Any

  func buildTree(for view: AnyView, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    return view.bodyBuild(context)
  }
  
  
  // MARK: - Text
  
  func buildTree(for view: Text, in context: TreeStateContext) -> HTMLTreeNode {
    return HTMLTextNode(elementID: context.currentElementID, view.runs.map {
      run in
      // Note: we still emit spans for empty runs, because they might get
      //       filled later?
      // FIX this non-beauty
      // TBD: support nil applies?
      switch run {
        case .verbatim(let s):
          var modifiers = [ Text.Modifier ]()
          modifiers.enrichingTextModifiers(from: context)
          return Text.Run(content: s, modifiers: modifiers)
        
        case .styled(let s, var modifiers):
          modifiers.enrichingTextModifiers(from: context)
          return Text.Run(content: s, modifiers: modifiers)
      }
    })
  }
  
  // MARK: - Child Build Helpers
  
  func _buildContent<Content: View>(_ content: Content,
                                    in context: TreeStateContext)
       -> HTMLTreeNode
  {
    context.appendContentElementIDComponent()
    defer { context.deleteLastElementIDComponent() }
    let childTree = buildTree(for: content, in: context)
    return childTree
  }
  
  func _buildInLayoutContext<Content: View>(_ content: Content,
                                            in context: TreeStateContext)
       -> HTMLTreeNode
  {
    context.enterLayoutContext()
    defer { context.leaveLayoutContext() }
    return _buildContent(content, in: context)
  }
  
  func _buildContent<Content: View, T1: Trait>(
         _ content: Content,
         collect trait: T1.Type,
         in context: TreeStateContext
       ) -> ( contentTree: HTMLTreeNode, traits: [ ElementID: T1 ] )
  {
    // crazy shit :->
    typealias TraitValues = ( elementID: ElementID, value: T1? )
    let ( childTree, traits ) : ( HTMLTreeNode, [ TraitValues ] )
      = context.collectingTraits(trait) {
        return _buildContent(content, in: context)
      }
    var eidToTrait = [ ElementID : T1 ]()
    for trait in traits {
      guard let value = trait.value else { continue }
      eidToTrait[trait.elementID] = value
    }
    return ( childTree, eidToTrait )
  }

  
  // MARK: - Layout
  
  func buildTree<Content: View>(for view: HStack<Content>,
                                in context: TreeStateContext)
       -> HTMLTreeNode
  {
    let childTree = _buildInLayoutContext(view.content, in: context)
    
    return FlexBoxStackNode(elementID: context.currentElementID,
                            orientation: .horizontal,
                            alignment: view.alignment, spacing: view.spacing,
                            localLayout: context.localLayoutInfo,
                            content: childTree)
  }
  func buildTree<Content: View>(for view: VStack<Content>,
                                in context: TreeStateContext) -> HTMLTreeNode
  {
    let childTree = _buildInLayoutContext(view.content, in: context)

    return FlexBoxStackNode(elementID: context.currentElementID,
                            orientation: .vertical,
                            alignment: view.alignment, spacing: view.spacing,
                            localLayout: context.localLayoutInfo,
                            content: childTree)
  }
  func buildTree<Content: View>(for view: ScrollView<Content>,
                                in context: TreeStateContext) -> HTMLTreeNode
  {
    let childTree = _buildContent(view.content, in: context)
    return HTMLScrollNode(elementID: context.currentElementID,
                          content: childTree)
  }

  // MARK: - Control Structures

  func buildTree<Data, Content: View>(for view: ForEach<Data, Content>,
                                      in context: TreeStateContext)
       -> HTMLTreeNode
  {
    typealias IDAndWebID = ( id: Data.Element.ID, webID: String )
    var itemTrees = [ HTMLTreeNode ]()
    itemTrees.reserveCapacity(view.data.count)

    // TODO(perf):
    // Well, in here we already expand the child tree completely. Which is
    // not particularily efficient (imagine a loop of 100k items).
    // Technically this is not required, we could also yield child nodes on
    // demand.
    // The "only" tricky thing here is during diffing. While we could traverse
    // two trees in one run, we would have to produce two copies of the context.
    var ids = [ IDAndWebID ]()
    ids.reserveCapacity(view.data.count)
    for item in view.data {
      context.appendElementIDComponent(item.id)
      
      // Hmm, this doesn't pick the right makeWebID<Int> for 1...3 sequences,
      // but rather picks the "Hashable" version. Why?
      let webID = ElementID.makeWebID(for: item.id)
      
      let itemView = view.content(item)
      let itemTree = buildTree(for: itemView, in: context)
      ids.append( ( item.id, webID ) )
      itemTrees.append(itemTree)
      context.deleteLastElementIDComponent()
    }

    return ForEachNode(elementID: context.currentElementID,
                       ids: ids, children: itemTrees)
  }
  
  func buildTree<TrueContent: View, FalseContent: View>(
                for view: ConditionalContent<TrueContent, FalseContent>,
                in context: TreeStateContext) -> HTMLTreeNode
  {
    #if false
      // nope! we need to keep the tree ID stable, there are no two branches
      // on the client side!
    defer { context.deleteLastElementIDComponent() }
    
    switch view.content {
      case .first (let v):
        context.appendElementIDComponent(1)
        return ResolvedConditionNode(elementID: context.currentElementID,
                                     true, v.buildTree(in: context))
      case .second(let v):
        context.appendElementIDComponent(0)
        return ResolvedConditionNode(elementID: context.currentElementID,
                                     false, v.buildTree(in: context))
    }
    #else
    switch view.content {
      case .first (let v):
        return ResolvedConditionNode(elementID: context.currentElementID,
                                     true, buildTree(for: v, in: context))
      case .second(let v):
        return ResolvedConditionNode(elementID: context.currentElementID,
                                     false, buildTree(for: v, in: context))
    }
    #endif
  }
}
