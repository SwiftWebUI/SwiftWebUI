//
//  SUILabel.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SUILabel<Content: View, Detail: View>: View {

  let classes : [ String ]
  let image   : Image?
  let detail  : Detail?
  let content : Content
  
  public init(_ image: Image? = nil, _ color: Color? = nil,
              detail: Detail,
              @ViewBuilder content: () -> Content)
  {
    self.classes = makeClasses(hasImage: image != nil, color: color)
    self.image   = image
    self.detail  = detail
    self.content = content()
  }
  
  var hasImage: Bool { return image != nil }
  
  public var body: some View {
    HTMLContainer("a", classes: classes) {
      if hasImage { image! }
      else {}

      content
      
      if detail != nil {
        HTMLContainer(classes: ["detail"]) {
          detail!
        }
      }
      else {}
    }
  }
}
public extension SUILabel where Detail == EmptyView {
  init(_ image: Image? = nil, _ color: Color? = nil,
       @ViewBuilder content: () -> Content)
  {
    self.classes = makeClasses(hasImage: image != nil, color: color)
    self.image   = image
    self.detail  = nil
    self.content = content()
  }
}

fileprivate func makeClasses(hasImage: Bool, color: Color?) -> [ String ] {
  var classes = [ String ]()
  classes.reserveCapacity(4)
  classes.append("ui")
  if let color = color { classes.append(color.cssStringValue) }
  if hasImage { classes.append("image") }
  classes.append("label")
  return classes
}
