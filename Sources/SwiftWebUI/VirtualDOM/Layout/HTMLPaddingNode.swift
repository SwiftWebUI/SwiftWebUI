//
//  HTMLPaddingNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 25.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLPaddingNode: HTMLWrappingNode {
  
  let elementID       : ElementID
  let value           : PaddingLayout.Value
  let localLayoutInfo : LocalLayoutInfo?
  let content         : HTMLTreeNode

  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLPaddingNode(elementID: elementID, value: value,
                           localLayoutInfo: localLayoutInfo,
                           content: newContent)
  }

  var styles: CSSStyles {
    var styles : CSSStyles = {
      switch value {
        case .insets(let insets):
          return [ .padding: insets ]
        
        case .edges(let edges, let length):
          let defaultLength = Length.fontSize(0.5)
          let applyLength   = length ?? defaultLength
          
          if edges.contains(.all) {
            let insets = EdgeInsets(applyLength)
            return [ .padding: insets ]
          }

          var styles = CSSStyles()
          if edges.contains(.bottom)   { styles[.paddingBottom] = applyLength }
          if edges.contains(.top)      { styles[.paddingTop]    = applyLength }
          if edges.contains(.leading)  { styles[.paddingLeft]   = applyLength }
          if edges.contains(.trailing) { styles[.paddingRight]  = applyLength }
          return styles
      }
    }()
    
    // another hack to get spacers to work ...
    
    if let v = localLayoutInfo?.width  { styles[.width]  = v }
    else if let stack = content as? FlexBoxStackNode,
         stack.containsSpacer
    {
      styles[.width] = Length.percent(100)
    }
    
    if let v = localLayoutInfo?.height { styles[.height] = v }
    else if let stack = content as? FlexBoxStackNode,
         stack.containsSpacer
    {
      styles[.height] = Length.percent(100)
    }
    
    return styles
  }

  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-padder\""
    html.appendAttribute("id",    elementID.webID)
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
    
    if oldNode.value != value {
      changeset.append(
        .setAttribute(webID: elementID.webID, attribute: "style",
                      value: styles.cssStringValue ?? "")
      )
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
  
  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Padder: \(value)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</Padder>")
  }
}
