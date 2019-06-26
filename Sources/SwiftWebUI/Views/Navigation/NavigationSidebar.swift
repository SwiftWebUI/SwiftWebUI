//
//  NavigationSidebar.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

struct NavigationSidebar<Root: View>: View {
  
  let root : Root
  
  var body: some View {
    HTMLContainer(classes: [ "swiftui-nav-sidebar" ]) {
      root
    }
  }
}

