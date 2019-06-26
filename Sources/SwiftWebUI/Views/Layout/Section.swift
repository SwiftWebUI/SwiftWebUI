//
//  Section.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct Section<Header: View, Content: View, Footer: View>: View {

  let header  : Header?
  let content : Content
  let footer  : Footer?
  
  public init(header: Header, footer: Footer,
              @ViewBuilder content: () -> Content)
  {
    self.header  = header
    self.content = content()
    self.footer  = footer
  }

  public var body: some View {
    HTMLContainer {
      if header != nil {
        HTMLContainer("h4", classes: [ "ui", "top", "attached", "header" ]) {
          header!
        }
      }
      else {}
      
      HTMLContainer(classes: ["ui", "attached", "segment" ]) {
        content
      }
      
      if footer != nil {
        HTMLContainer(classes: ["ui", "bottom", "attached", "segment" ]) {
          footer!
        }
      }
      else {}
    }
  }
}

public extension Section where Header == EmptyView {
  init(footer: Footer, content: () -> Content) {
    self.header = nil
    self.content = content()
    self.footer  = footer
  }
}
public extension Section where Footer == EmptyView {
  init(header: Header, content: () -> Content) {
    self.header  = header
    self.content = content()
    self.footer  = nil
  }
}
public extension Section where Header == EmptyView, Footer == EmptyView {
  init(content: () -> Content) {
    self.header  = nil
    self.content = content()
    self.footer  = nil
  }
}
