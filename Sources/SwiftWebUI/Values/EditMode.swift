//
//  EditMode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum EditMode: Hashable {
  
  case inactive, transient, active
  
  public var isEditing: Bool {
    switch self {
      case .inactive:           return false
      case .transient, .active: return true
    }
  }
}
