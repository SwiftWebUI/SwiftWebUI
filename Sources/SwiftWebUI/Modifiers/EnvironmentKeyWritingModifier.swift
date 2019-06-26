//
//  EnvironmentKeyWritingModifier.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public extension View {

  func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>,
                      _ value: V)
       -> ModifiedContent<Self, EnvironmentKeyWritingModifier<V>>
  {
    return modifier(EnvironmentKeyWritingModifier(keyPath, value))
  }
  
}

public struct EnvironmentKeyWritingModifier<Value>: ViewModifier {

  typealias EnvironmentKeyPath = WritableKeyPath<EnvironmentValues, Value>
  
  private let keyPath : EnvironmentKeyPath
  private let value   : Value

  init(_ keyPath: EnvironmentKeyPath, _ value: Value) {
    self.keyPath = keyPath
    self.value   = value
  }

  public func push(to context: TreeStateContext) {
    var newEnvironment = context.environment
    newEnvironment[keyPath: keyPath] = value
    context.environmentStack.append(newEnvironment)
  }
  public func pop(from context: TreeStateContext) {
    context.environmentStack.removeLast()
  }
}
