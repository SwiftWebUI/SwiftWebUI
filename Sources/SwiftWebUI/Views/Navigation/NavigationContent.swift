//
//  NavigationContent.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct NavigationContent: View {
  
  @EnvironmentObject private var navigationContext: NavigationContext
  
  var body: some View {
    HTMLContainer(classes: [ "swiftui-nav-content" ],
                  styles: [ .flexGrow: 5 ])
    {
      SwitchView(navigationContext.activeTargetView)
        .padding(.fontSize(0.5))
    }
  }
}
