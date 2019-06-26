//
//  SUIFlag.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SUIFlag: View {
  
  let clazz : String
  
  public init(code: String) {
    clazz = code.lowercased()
  }
  public init(_ name: String) {
    clazz = name.lowercased()
  }
  
  public var body: some View {
    HTMLContainer("i", classes: [ clazz, "flag" ]) {
      EmptyView()
    }
  }
}
