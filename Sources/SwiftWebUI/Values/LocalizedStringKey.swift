//
//  LocalizedStringKey.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct LocalizedStringKey: Equatable, ExpressibleByStringInterpolation {

  let value : String
  
  public init(_ value: String) {
    self.value = value
  }
  public init(stringLiteral value: String) {
    self.value = value
  }
  
  // support the interpolation stuff
}
  
