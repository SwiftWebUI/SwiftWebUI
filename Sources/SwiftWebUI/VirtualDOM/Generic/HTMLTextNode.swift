//
//  HTMLTextNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct HTMLTextNode : HTMLLeafNode, CustomStringConvertible {
  
  typealias Run = Text.Run
  
  let         elementID : ElementID
  private let runs      : [ Run ]
  
  init(elementID: ElementID, _ runs: [ Run ]) {
    self.elementID = elementID
    self.runs      = runs
  }
  
  private func computeStyles(for run: Text.Run) -> CSSStyles? {
    // Note: Those work on _resolved_ texts!
    guard case .styled(_, let modifiers) = run else { return nil }
    guard !modifiers.isEmpty                   else { return nil }
    
    var styles = CSSStyles()
    for modifier in modifiers {
      switch modifier {
        case .italic: styles[.fontStyle]  = "italic"
        case .bold:   styles[.fontWeight] = "bold"
        
        case .color(let color):
          styles[.color] = color?.cssStringValue ?? "initial"
        
        case .font(let font):
          if let size = font?.size {
            styles[.fontSize] = size.cssStringValue
          }
          if let name = font?.name {
            styles[.fontFamily] = name.quotedCSSStringValue
          }
          //let style  : TextStyle
          //let design : Design
        
        case .shadow(let shadow):
          styles[.textShadow] = shadow.cssStringValue
      }
    }
    return styles
  }
  
  private func computeClasses(for run: Text.Run) -> [ String ] {
    // Note: Those work on _resolved_ texts!
    guard case .styled(_, let modifiers) = run else { return [] }
    guard !modifiers.isEmpty                   else { return [] }

    var classes = [ String ]()
    for modifier in modifiers {
      guard case .font(let font) = modifier else { continue }
      guard let style = font?.style else { continue }
      
      switch style {
        case .body:        classes.append("swiftui-body")
        case .largeTitle:  classes.append("swiftui-large-title")
        case .title:       classes.append("swiftui-title")
        case .headline:    classes.append("swiftui-headline")
        case .subheadline: classes.append("swiftui-subheadline")
        case .callout:     classes.append("swiftui-callout")
        case .footnote:    classes.append("swiftui-footnote")
        case .caption:     classes.append("swiftui-caption")
      }
    }
    return classes
  }

  func generateHTML(into html: inout String) {
    // TBD: We could use <h1> etc, but this makes it harder to update?
    html += "<div class=\"swiftui-text\""
    html.appendAttribute("id", elementID.webID)
    html += ">"
    defer { html += "</div>" }
    
    generateInnerHTML(into: &html)
  }
  
  func generateInnerHTML(into html: inout String) {
    let baseID = elementID.webID
    
    for ( i, run ) in runs.enumerated() {
      let classes : String? = {
        let classes = computeClasses(for: run)
        guard !classes.isEmpty else { return nil }
        return classes.joined(separator: " ")
      }()
      
      let styles = computeStyles(for: run)?.cssStringValue

      // because we might want to address specific runs
      html += "<span"
      html.appendAttribute("id", "\(baseID).\(i)")
      if classes != nil { html.appendAttribute("class", classes) }
      if styles  != nil { html.appendAttribute("style", styles)  }
      html += ">"
      defer { html += "</span>" }
      
      html.appendContentHTMLString(run.contentString)
    }
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    guard oldNode.runs != runs else { return }
    
    // TODO: make this more clever!!!
    var html = ""
    generateInnerHTML(into: &html)
    changeset.append(
      .replaceElementContentsWithHTML(webID: elementID.webID, html: html)
    )
  }
  
  
  // MARK: - Debugging
  
  var description: String { return "<Text[\(elementID.webID)]: \(runs)>" }
  
  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)\(self)")
  }
}

extension String {
  var quotedCSSStringValue : String {
    // FIXME: This is really a font name
    return "\"" + self + "\"" // FIXME: escape ;-)
  }
}
