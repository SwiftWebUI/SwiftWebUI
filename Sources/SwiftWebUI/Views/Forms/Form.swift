//
//  Form.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct Form<Content: View> : View {
  // In our case a Form is just CSS styling, isn't it?
  // The CSS for this would appreciate some love ;-) Using a VStack for now.
  
  let content : VStack<Content>
  
  public init(@ViewBuilder content: () -> Content) {
    self.content = VStack(content: content)
  }
  
  public var body: some View {
    return HTMLContainer("form", classes: [ "swiftui-form", "ui", "form" ]) {
      content
    }
  }
  
}
