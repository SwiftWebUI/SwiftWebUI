//
//  SUIInputNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct SUIInputNode: HTMLLeafNode {
  
  let elementID        : ElementID
  var value            : String
  var binding          : Binding<String>
  let placeholder      : String?
  let isEnabled        : Bool
  let isPassword       : Bool
  let onEditingChanged : (( Bool ) -> Void)?
  let onCommit         : (()       -> Void)?

  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    context.ignoreValueChange(value, for: elementID)
    binding.value = value
  }
  
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    guard elementID.isContainedInWebID(webID) else { return }
    
    // FIXME: just add the event type to the elementID?
    guard elementID.count + 1 == webID.count else { return }
    let componentID = webID[elementID.count]
    
    switch componentID {
      case "change":
        // flag says whether the field has focus
        onEditingChanged?(true)
      case "commit":
        onEditingChanged?(false)
        onCommit?()
      default:
        print("ERROR: unexpected textfield component:", componentID, webID)
        assertionFailure("unexpected textfield component")
    }
  }
  
  func generateHTML(into html: inout String) {
    let disabledClass = isEnabled ? "" : " disabled"
    html += "<div class=\"swiftui-textfield ui input\(disabledClass)\""
    html.appendAttribute("id", outerDivWebID)
    html += ">"
    if isPassword { html += "<input type=\"password\"" }
    else          { html += "<input type=\"text\""     }
    html.appendAttribute("id", elementID.webID)
    if let s = placeholder { html.appendAttribute("placeholder", s) }
    html.appendAttribute("value", value)
    html.appendAttribute("oninput",  "SwiftUI.valueChanged(this);")
    html.appendAttribute("onchange", "SwiftUI.valueCommit(this);")
    html += ">"
    html += "</div>"
  }

  private var outerDivWebID: String {
    return elementID.webID + ".X"
  }

  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    if oldNode.value != value,
       !context.shouldIgnoreValueChange(value, for: elementID)
    {
      changeset.append(
        .setAttribute(webID: elementID.webID,
                      attribute: "value", value: value)
      )
    }
    
    if oldNode.isPassword != isPassword {
      changeset.append(
        .setAttribute(webID: elementID.webID,
                      attribute: "type",
                      value: isPassword ? "password" : "text")
      )
    }

    if oldNode.isEnabled != isEnabled {
      // FIXME: need outer id!
      changeset.append(
        isEnabled ? .removeClass(webID: outerDivWebID, class: "disabled")
                  : .addClass   (webID: outerDivWebID, class: "disabled")
      )
    }
  }

  // MARK: - Debugging
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<TextField \(elementID.webID) \(value)>")
  }
}
