//
//  SUIToggleNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUIToggleNode: HTMLWrappingNode {
  
  let elementID : ElementID
  let isEnabled : Bool
  let isOn      : Bool
  let binding   : Binding<Bool>
  let content   : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return SUIToggleNode(elementID: elementID, isEnabled: isEnabled,
                         isOn: isOn, binding: binding,
                         content: newContent)
  }
  
  func takeValue(_ webID: [String], value: String,
                 in context: TreeStateContext) throws
  {
    context.ignoreValueChange(value, for: elementID)
    binding.wrappedValue = value == "on"
  }
  
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    if elementID.count == webID.count {
      return // this actually does happen, we also get the invoke call
    }
    else {
      try content.invoke(webID, in: context)
    }
  }
  
  private var outerDivWebID: String {
    return elementID.webID + ".X"
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.isEnabled != isEnabled {
      changeset.append(
        isEnabled ? .removeClass(webID: outerDivWebID, class: "disabled")
                  : .addClass   (webID: outerDivWebID, class: "disabled")
      )
      if isEnabled {
        changeset.append(
          .setAttribute(webID: elementID.webID, attribute: "disabled",
                        value: "disabled")
        )
      }
      else {
        changeset.append(
          .removeAttribute(webID: elementID.webID, attribute: "disabled")
        )
      }
    }
    
    if oldNode.isOn != isOn {
      if isOn {
        changeset.append(.addClass(webID: outerDivWebID, class: "checked"))
      }
      else {
        changeset.append(
          .removeClass(webID: outerDivWebID, class: "checked")
        )
      }
      
      // FIXME: this needs to patch the "checked" attribute (add/remove)
      
      let v = isOn ? "on" : "off"
      if !context.shouldIgnoreValueChange(v, for: elementID) {
        changeset.append(
          .setAttribute(webID: elementID.webID, attribute: "value",
                        value: v)
        )
        if isOn {
          changeset.append(
            .setAttribute(webID: elementID.webID, attribute: "checked",
                          value: "checked")
          )
        }
        else {
          changeset.append(
            .removeAttribute(webID: elementID.webID, attribute: "checked")
          )
        }
      }
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }

  func generateHTML(into html: inout String) {
    // TODO: this wants the 'checked' class
    let v = isOn ? "on" : "off"
    let checkedClass = isOn ? " checked" : ""
    let enabledClass = isEnabled ? "" : " disabled"
    html += "<div class="
    html += "'swiftui-toggle ui toggle checkbox"
    html += "\(checkedClass)\(enabledClass)'"
    html.appendAttribute("id", outerDivWebID)
    html += ">"
    defer { html += "</div>" }
    
    html += "<input type='checkbox'"
    html.appendAttribute("id", elementID.webID)
    html.appendAttribute("value", v)
    html.appendAttribute("onchange", "SwiftUI.checkboxChanged(this);")
    if isOn       { html.appendAttribute("checked", "checked") }
    if !isEnabled { html.appendAttribute("disabled", "disabled") }
    html += ">"
    
    html += "<label"
    html.appendAttribute("id", elementID.webID + ".-")
    html.appendAttribute("for", elementID.webID)
    html += ">"
    defer { html += "</label>" }
    
    content.generateHTML(into: &html)
  }

  // MARK: - Debugging
  
  var children  : [ HTMLTreeNode ] { return [ content ] }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Toggle \(elementID.webID) \(isOn)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)<Toggle/>")
  }
}
