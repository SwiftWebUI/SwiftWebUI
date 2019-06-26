//
//  HTMLContainer.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if false // TODO:
public enum HTMLTag: String {
  case div
  case other(String)
}
#endif

public struct HTMLContainer<Content: View> : View {
  // FIXME: confusing body/content mismatch

  public let body  : Content
  let        value : HTMLTagInfo
  
  public init(_ tag      : String = "div",
              attributes : [ String : String? ]? = nil,
              classes    : [ String ]? = nil,
              styles     : CSSStyles? = nil,
              @ViewBuilder body: () -> Body)
  {
    self.value = HTMLTagInfo(tag: tag, attributes: attributes,
                             classes: classes, styles: styles)
    self.body = body()
  }
}

extension HTMLTreeBuilder {
  func buildTree<Content: View>(for view: HTMLContainer<Content>,
                                in context: TreeStateContext) -> HTMLTreeNode
  {
    context.appendContentElementIDComponent()
    let childTree = buildTree(for: view.body, in: context)
    context.deleteLastElementIDComponent()
    
    return HTMLContainerNode(elementID: context.currentElementID,
                             value: view.value, content: childTree)
  }
}

extension HTMLContainer: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}

struct HTMLTagInfo: Equatable {
  
  let tag        : String
  let attributes : [ String : String? ]?
  let classes    : [ String ]?
  let styles     : CSSStyles?
  
  static func == (lhs: HTMLTagInfo, rhs: HTMLTagInfo) -> Bool {
    // CSSStyleValue erases the conformance
    guard lhs.attributes == rhs.attributes else { return false }
    guard lhs.classes    == rhs.classes    else { return false }
    
    switch ( lhs.styles, rhs.styles ) {
      case ( .none, .none ): break
      case ( .some, .none), ( .none, .some ): return false
      case ( .some(let lhs), .some(let rhs) ):
        guard lhs.count == rhs.count else { return false }
        for ( key, value ) in lhs {
          guard let rhsValue = rhs[key] else { return false }
          guard value.cssStringValue == rhsValue.cssStringValue else {
            return false
          }
          break
        }
    }
    
    return lhs.tag == rhs.tag
  }
}
