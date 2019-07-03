//
//  SUIListBuilder.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

extension HTMLTreeBuilder { // Lists
  
  func buildTree<Selection: SelectionManager, Content: View>(
         for view: List<Selection, Content>,
         in context: TreeStateContext
       ) -> HTMLTreeNode
  {
    typealias SelectionValue = Selection.SelectionValue
    typealias TagTrait = ViewTag<SelectionValue>
    let ( childTree, traits ) = _buildContent(view.content,
                                              collect: TagTrait.self,
                                              in: context)

    let enrichedChildTree = childTree.rewrite { node in
      guard node.isContentNode else { return .recurse  }
      
      let tag = traits[node.elementID]?.value

      let isSelected : Bool = {
        guard let tag = tag else { return false }
        return view.selection?.wrappedValue.isSelected(tag) ?? false
      }()
      
      var contentNode = node
      
      #if false // OK, we now do this in CSS
        // Why? Because this is not sufficient:
        // <HStack .center DynamicElementNode<NavigationButton<LandmarkListInfo, Text>> eid=/._._._.0._.0._._.3>
        if let button = node as? SUIButtonNode {
          let clickContainer = HTMLClickContainerNode(
            elementID: button.elementID, isEnabled: button.isEnabled,
            isDouble: false, action: button.action, content: button.content
          )
          contentNode = clickContainer
        }
      #endif

      let tcID = node.elementID.appendingElementIDComponent("-")
      return .replaceAndReturn(newNode:
        SUIListItemNode(elementID  : tcID,
                        selection  : view.selection,
                        value      : tag,
                        isSelected : isSelected,
                        content    : contentNode)
      )
    }
    
    return SUIListNode(elementID : context.currentElementID,
                       selection : view.selection,
                       content   : enrichedChildTree)
  }
}
