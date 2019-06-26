//
//  SUISegment.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 17.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SUISegment<Content: View>: View {
  // TODO: clean this up
  
  let styles  : CSSStyles?
  let content : Content
  
  public init(width  : Length? = .percent(100),
              height : Length? = nil,
              @ViewBuilder content: () -> Content)
  {
    // TODO: support relativeHeight
    var styles = CSSStyles()
    if let v = width  { styles[.width]  = v }
    if let v = height { styles[.height] = v }
    self.styles = styles.isEmpty ? nil : styles
    self.content = content()
  }
  
  public var body: some View {
    HTMLContainer(classes: ["ui", "segment"], styles: styles) {
      content
    }
  }
}
