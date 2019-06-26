//
//  SUICard.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SUICards<Content: View>: View {
  // Wrap cards in those to please SUI

  let content : Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  public var body: some View {
    HTMLContainer(classes: ["ui", "cards"]) { content }
  }

}

public struct SUICard<Content: View>: View {
  
  let image        : Image
  let header       : Text?
  let meta         : AnyView?
  let content      : Content
  let extraContent : AnyView?
  
  public init(_ image: Image, _ header: Text? = nil,
              extra: AnyView? = nil,
              @ViewBuilder content: () -> Content)
  {
    self.image        = image
    self.header       = header
    self.meta         = nil
    self.extraContent = extra
    self.content      = content()
  }
  public init<M: View>(_ image: Image, _ header: Text? = nil,
                       meta: M, extra: AnyView? = nil,
                       @ViewBuilder content: () -> Content)
  {
    self.image        = image
    self.header       = header
    self.meta         = AnyView(meta)
    self.extraContent = extra
    self.content      = content()
  }

  public var body: some View {
    HTMLContainer(classes: [ "ui", "card" ]) {
      
      HTMLContainer(classes: [ "image" ]) {
        image
      }
      
      HTMLContainer(classes: [ "content" ]) {
        if header != nil {
          HTMLContainer("a", classes: [ "header" ]) { header! }
        }
        else {}
        if meta != nil {
          HTMLContainer(classes: [ "meta" ]) { meta! }
        }
        else {}
        
        if !(content is EmptyView) {
          HTMLContainer(classes: [ "description" ]) { content }
        }
        else {}
      }
    }
  }
}

public extension SUICard where Content == EmptyView {
  init(_ image: Image, _ header: Text? = nil,
       meta: AnyView? = nil, extra: AnyView? = nil)
  {
    self.image        = image
    self.header       = header
    self.meta         = meta
    self.extraContent = extra
    self.content      = EmptyView()
  }
}
