//
//  NavigationBarItem.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct NavigationBarItem {
  public enum TitleDisplayMode: Hashable {
    case automatic, inline, large
  }

  let view        : AnyView
  let displayMode : NavigationBarItem.TitleDisplayMode
}
