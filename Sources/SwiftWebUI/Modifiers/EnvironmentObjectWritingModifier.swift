//
//  EnvironmentObjectWritingModifier.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 21.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public extension View {

  func environmentObject<O: ObservableObject>(_ object: O)
       -> Self.Modified<EnvironmentObjectWritingModifier<O>>
  {
    return modifier(EnvironmentObjectWritingModifier(object))
  }
}

public struct EnvironmentObjectWritingModifier<O: ObservableObject>
              : ViewModifier
{
  private let object : O
  
  init(_ object: O) {
    self.object = object
  }
  
  public func push(to context: TreeStateContext) {
    var newEnvironment = context.environment
    newEnvironment[EnvironmentObjectKey<O>.self] = object
    context.environmentStack.append(newEnvironment)
  }
  public func pop(from context: TreeStateContext) {
    context.environmentStack.removeLast()
  }
}
