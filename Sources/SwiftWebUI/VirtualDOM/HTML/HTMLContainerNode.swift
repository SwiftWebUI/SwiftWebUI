//
//  HTMLContainerNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLContainerNode: HTMLWrappingNode {
  
  let elementID : ElementID
  let value     : HTMLTagInfo
  let content   : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLContainerNode(elementID: elementID, value: value,
                             content: newContent)
  }
  
  // FIXME: Beautify
  
  var classes: String? {
    let aclass1 = value.attributes?["class"]
    
    if let classes = value.classes, !classes.isEmpty {
      if let aclass2 = aclass1, let aclass = aclass2, !aclass.isEmpty {
        return aclass + " " + classes.joined(separator: " ")
      }
      else {
        return classes.joined(separator: " ")
      }
    }
    else if let aclass = aclass1 {
      return aclass
    }
    return nil
  }
  var styles: String? {
    if let styles = value.styles {
      if let astyle1 = value.attributes?["style"], let astyle = astyle1,
        !astyle.isEmpty
      {
        return astyle + "; " + (styles.cssStringValue ?? "")
      }
      else { return styles.cssStringValue }
    }
    else if let astyle1 = value.attributes?["style"], let astyle = astyle1,
            !astyle.isEmpty
    {
      return astyle
    }
    else { return nil }
  }

  func generateHTML(into html: inout String) {
    html += "<" + value.tag
    html.appendAttribute("id", elementID.webID)
    
    if let v = classes { html.appendAttribute("class", v) }
    if let v = styles  { html.appendAttribute("style", v) }
    
    if let attrs = value.attributes {
      for ( name, value ) in attrs {
        if name == "style" { continue }
        if name == "class" { continue }
        if name == "id"    { continue } // TBD: what we want here
        html.appendAttribute(name, value)
      }
    }
    
    html += ">"
    
    defer { html += "</\(value.tag)>" }
    
    content.generateHTML(into: &html)
  }
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.value != value {
      if oldNode.value.tag != value.tag {
        var html = ""
        generateHTML(into: &html)
        let change = HTMLChange
          .replaceElementWithHTML(webID: elementID.webID, html: html)
        changeset.append(change)
        return
      }

      if oldNode.styles != styles {
        if let styles = styles {
          changeset.append(
            .setAttribute(webID: elementID.webID,
                          attribute: "style", value: styles)
          )
        }
        else {
          changeset.append(
            .removeAttribute(webID: elementID.webID, attribute: "style")
          )
        }
      }
      
      if oldNode.classes != classes {
        if let classes = classes, !classes.isEmpty {
          changeset.append(
            .setAttribute(webID: elementID.webID,
                          attribute: "class", value: classes)
          )
        }
        else {
          changeset.append(
            .removeAttribute(webID: elementID.webID, attribute: "class")
          )
        }
      }
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                          in: context)
  }

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<HTMLContainer: \(value)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</HTMLContainer>")
  }
}
