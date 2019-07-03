//
//  BindingConvertible.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@dynamicMemberLookup public protocol BindingConvertible {
  // Kinda like objects being able to vend a WOAssociation
  // `State` is a BindingConvertible.
  
  associatedtype Value
  
  var binding : Binding<Self.Value> { get }
  
  subscript<Subject>(dynamicMember path: WritableKeyPath<Self.Value, Subject>)
                     -> Binding<Subject> { get }
}

public extension BindingConvertible {

  subscript<Subject>(dynamicMember path: WritableKeyPath<Self.Value, Subject>)
                     -> Binding<Subject>
  {
    return Binding(getValue: { return self.binding.wrappedValue[keyPath: path] },
                   setValue: { self.binding.wrappedValue[keyPath: path] = $0 })
  }
}

public extension BindingConvertible {
  
  func zip<T: BindingConvertible>(with rhs: T)
       -> Binding< ( Self.Value, T.Value ) >
  {
    return Binding(
      getValue: { return ( self.binding.wrappedValue, rhs.binding.wrappedValue ) },
      setValue: { ( newLHS, newRHS ) in
        self.binding.wrappedValue = newLHS
        rhs.binding.wrappedValue  = newRHS
      }
    )
  }
  
}

extension Binding : BindingConvertible {

  public var binding : Self { return self }

}
