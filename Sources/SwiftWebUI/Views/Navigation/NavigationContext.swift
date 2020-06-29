//
//  NavigationContext.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if USE_COMBINE
import Combine
#elseif USE_COMBINEX
import CombineX
#elseif USE_OPEN_COMBINE
import OpenCombine
#endif

final class NavigationContext: ObservableObject {
  
  private(set) var activeTargetView : AnyView {
    didSet { didChange.send(()) }
  }
  
  init(_ initialTargetView: AnyView) {
    self.activeTargetView = initialTargetView
  }
  init<V: View>(_ initialTargetView: V) {
    self.activeTargetView = AnyView(initialTargetView)
  }
  
  func navigate<V: View>(to view: V) {
    activeTargetView = AnyView(view)
  }
  func navigate(to view: AnyView) {
    activeTargetView = view
  }

  var didChange = PassthroughSubject<Void, Never>()
}

extension NavigationContext: CustomStringConvertible {
  var description: String {
    return "<NavCtx: \(self.pointerDescription) \(activeTargetView.viewType)>"
  }
}
