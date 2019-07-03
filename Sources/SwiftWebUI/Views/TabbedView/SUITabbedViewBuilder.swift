//
//  SUITabbedViewBuilder.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

extension HTMLTreeBuilder {
  
  fileprivate typealias TabbedViewTraitValues<SelectionValue: Hashable> = (
    elementID : ElementID,
    tag       : ViewTag<SelectionValue>?,
    labelView : TabItemLabel?
  )
  
  func buildTree<SelectionValue: Hashable, Content: View>(
                for view: SUITabbedView<SelectionValue, Content>,
                in context: TreeStateContext
       ) -> HTMLTreeNode
  {
    typealias TraitValues = TabbedViewTraitValues<SelectionValue>
    
    let currentSelection = view.selection.wrappedValue
    
    // crazy shit :->
    let ( childTree, traits ) : ( HTMLTreeNode, [ TraitValues ] )
      = context.collectingTraits(
                  ViewTag<SelectionValue>.self, TabItemLabel.self)
    {
      return _buildContent(view.content, in: context)
    }
    
    var eidToTrait = [ ElementID : TraitValues ]()
    for trait in traits { eidToTrait[trait.elementID] = trait }
    
    let childNodes = childTree.collectDirectContentNodes()
    
    let tabItems = buildTabItems(for: childNodes,
                                 currentSelection: currentSelection,
                                 traits: eidToTrait,
                                 in: context)
    
    var i = 0
    let enrichedChildTree = childTree.rewrite { node in
      guard node.isContentNode else {
        return .recurse
      }
      
      defer { i += 1 }
      
      let ( _, traitTag, _ ) = eidToTrait[node.elementID]
                            ?? ( node.elementID, nil, nil )
      // FIXME: code dupe
      let tagOpt : SelectionValue? = traitTag?.value ?? {
        if let v = i         as? SelectionValue { return v }
        if let v = String(i) as? SelectionValue { return v }
        return nil
      }()
      guard let tag = tagOpt else {
        print("missing tag for tabbedview: \(self)")
        return .replaceAndReturn(newNode: node) // 'keep'?
      }
      
      let tcID = node.elementID.appendingElementIDComponent("|")
      return .replaceAndReturn(newNode:
        SUITabSegmentNode(elementID: tcID, isSelected: currentSelection == tag,
                          content: node)
      )
    }
    
    return SUITabContainerNode(elementID : context.currentElementID,
                               selection : view.selection.wrappedValue,
                               tabItems  : tabItems,
                               content   : enrichedChildTree)
  }
  
  fileprivate
  func buildTabItems<SelectionValue: Hashable>(
         for childNodes   : [ HTMLTreeNode ],
         currentSelection : SelectionValue,
         traits           : [ ElementID : TabbedViewTraitValues<SelectionValue> ],
         in       context : TreeStateContext
       ) -> TypedCompoundNode<SUITabItemNode>
  {
    context.appendElementIDComponent("|")
    defer { context.deleteLastElementIDComponent() }
    
    var items = [ SUITabItemNode ]()
    items.reserveCapacity(traits.count)
    
    for ( i, child ) in childNodes.enumerated() {
      // for ( i, ( elementID, tag, labelView) ) in traits.enumerated() {
      let ( elementID, traitTag, traitView ) = traits[child.elementID]
                                            ?? ( child.elementID, nil, nil )
      
      let tagOpt : SelectionValue? = traitTag?.value ?? {
        if let v = i         as? SelectionValue { return v }
        if let v = String(i) as? SelectionValue { return v }
        return nil
      }()
      guard let tag = tagOpt else {
        print("missing tag for tabbedview: \(self)")
        continue
      }

      let webID = ElementID.makeWebID(for: tag)
      context.appendElementIDComponent(webID)
      defer { context.deleteLastElementIDComponent() }

      let labelView = traitView?.value ?? AnyView(Text("\(tag)"))
      let labelNode = context.currentBuilder.buildTree(for: labelView,
                                                       in: context)
      
      let dataTab = elementID.appendingElementIDComponent("|")
      let item = SUITabItemNode(elementID  : context.currentElementID,
                                isSelected : tag == currentSelection,
                                contentID  : dataTab,
                                content    : labelNode)
      items.append(item)
    }
    
    return TypedCompoundNode(elementID: context.currentElementID,
                             children: items)
  }

}
