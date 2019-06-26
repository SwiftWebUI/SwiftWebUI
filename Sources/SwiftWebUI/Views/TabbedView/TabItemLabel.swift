//
//  TabItemLabel.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 18.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import Foundation

public extension View {

  func tabItemLabel<V: View>(_ item: V)
       -> Self.Modified<TraitWritingModifier<TabItemLabel>>
  {
    // The official doesn't carry a type here, but just `AnyView?`. Hm.
    return modifier(TraitWritingModifier(content:
                      TabItemLabel(value: AnyView(item))))
  }
}

public struct TabItemLabel: Trait {
  public typealias Value = AnyView
  let value : AnyView
}
