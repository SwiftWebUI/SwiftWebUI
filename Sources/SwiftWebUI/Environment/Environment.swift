//
//  Environment.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@propertyDelegate
public struct Environment<Value>: DynamicViewProperty {
  
  // (\EnvironmentValues.isEnabled) or just (\.isEnabled)
  let keyPath : KeyPath<EnvironmentValues, Value>
  
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    self.keyPath = keyPath
  }
  
  // DynamicViewProperty
  // update => this updates the value from the environment I think
  // how do we receive the environment? Is that a global?

  private var _value: Value?

  public var value: Value {
    guard let value = _value else {
      fatalError("you cannot access @Environment outside of `body`")
    }
    return value
  }
  
  public mutating func update() {
    guard let context = DynamicViewPropertyHelpers.currentContext else {
      assertionFailure("you cannot access @Environment outside of `body`")
      return
    }
    
    _value = context.environment[keyPath: keyPath]
  }
}
