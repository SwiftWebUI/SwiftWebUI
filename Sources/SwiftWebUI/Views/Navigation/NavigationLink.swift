//
//  NavigationButton.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@available(*, deprecated, renamed: "NavigationLink")
public typealias NavigationButton = NavigationLink

public struct NavigationLink<Content: View, Destination: View>: View {
  // TBD: What is NavigationDestinationLink? Same like a navcontext?
  
  @EnvironmentObject private var navigationContext: NavigationContext
  
  private let destination : Destination
  private let onTrigger   : (() -> Bool)?
  private let content     : Content
  
  public init(destination : Destination,
              onTrigger   : (() -> Bool)? = nil,
              @ViewBuilder content: () -> Content)
  {
    self.destination = destination
    self.onTrigger   = onTrigger
    self.content     = content()
  }
  
  public var body: some View {
    Button(onClick) {
      content
    }
    .relativeWidth(1.0)
  }
  
  func onClick() {
    if let onTrigger = onTrigger, !onTrigger() { return }
    navigationContext.navigate(to: destination)
  }
}
