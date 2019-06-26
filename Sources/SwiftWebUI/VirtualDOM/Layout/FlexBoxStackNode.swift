//
//  FlexBoxStackNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 21.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct FlexBoxStackNode : HTMLWrappingNode, CustomStringConvertible {
  
  enum Orientation: Equatable {
    case horizontal, vertical
  }
  
  let elementID   : ElementID
  let orientation : Orientation
  let alignment   : CSSStyleValue
  let spacing     : Length?
  let localLayout : LocalLayoutInfo?
  let content     : HTMLTreeNode // type erased, hm
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return FlexBoxStackNode(elementID   : elementID,
                            orientation : orientation,
                            alignment   : alignment, spacing: spacing,
                            localLayout : localLayout,
                            content     : newContent)
  }
  
  var containsSpacer: Bool {
    return content.containsSpacer // we process our own spacers
  }

  var styles : CSSStyles {
    let hasSpacer = content.containsSpacer
    var styles = CSSStyles()
    if let v = localLayout?.width  { styles[.width]  = v }
    if let v = localLayout?.height { styles[.height] = v }
    else if hasSpacer {
      styles[orientation == .vertical ? .height : .width] = Length.percent(100)
    }
    if let spacing = spacing {
      styles[orientation == .vertical ? .vPadding : .hPadding] = spacing
    }
    
    #if false // no, that's not what we want - it stretches ALL children
      if hasSpacer { styles[.alignItems] = "stretch"  }
      else         { styles[.alignItems] = alignment  }
    #else
      styles[.alignItems] = alignment
    #endif
    
    return styles
  }

  func generateHTML(into html: inout String) {
    if orientation == .vertical {
      html += "<div class=\"swiftui-stack swiftui-vstack\""
    }
    else {
      html += "<div class=\"swiftui-stack swiftui-hstack\""
    }
    html.appendAttribute("id", elementID.webID)
    html.appendAttribute("style", styles.cssStringValue)
    html += ">"
    defer { html += "</div>" }
    
    content.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    // TODO: handle changes in spacing!
    
    if oldNode.spacing != spacing ||
       oldNode.alignment.cssStringValue != alignment.cssStringValue
    {
      changeset.append(.setAttribute(webID: elementID.webID,
                                     attribute: "style",
                                     value: styles.cssStringValue ?? ""))
    }
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  
  // MARK: - Debugging
  
  var description: String {
    let tag = orientation == .vertical ? "VStack" : "HStack"
    var ms = "<" + tag + " ." + alignment.cssStringValue
    if let spacing = spacing { ms += " spacing=" + spacing.cssStringValue }
    if let localLayout = localLayout, !localLayout.isEmpty {
      ms += " local=\(localLayout)"
    }
    ms += " \(type(of: content))"
    ms += " eid=" + elementID.webID
    ms += ">"
    return ms
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    let tag = orientation == .vertical ? "VStack" : "HStack"
    print("\(indent)<\(tag): \(alignment) \(spacing?.cssStringValue ?? "")>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</\(tag)>")
  }
}
