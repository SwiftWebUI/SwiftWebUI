//

struct HTMLShadowNode: HTMLWrappingNode {
  
  let elementID : ElementID
  let value     : ShadowModifier.Value
  let content   : HTMLTreeNode
  
  func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
    return HTMLShadowNode(elementID: elementID, value: value,
                          content: newContent)
  }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    let info = " color=\(value.color) radius=\(value.radius) x=\(value.x) y=\(value.y)"
    print("\(indent)<Shadow: \(elementID) \(info)>")
    content.dump(nesting: nesting + 1)
    print("\(indent)</Shadow>")
  }
  
  var styles: CSSStyles? {
    return [ .boxShadow: value]
  }

  func generateHTML(into html: inout String) {
    html += "<div class=\"swiftui-shadow\""
    html.appendAttribute("id", elementID.webID)
    if let v = styles?.cssStringValue { html.appendAttribute("style", v) }
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
      changeset.append(.setAttribute(webID: elementID.webID, attribute: "style",
                                     value: styles?.cssStringValue ?? ""))
    }
    
    content.generateChanges(from: oldNode.content, into: &changeset,
                            in: context)
  }
}
