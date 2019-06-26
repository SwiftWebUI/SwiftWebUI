//
//  EnvironmentValues.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct EnvironmentValues /*: CustomStringConvertible*/ {
  
  static let empty = EnvironmentValues()
  
  var values = [ ObjectIdentifier : Any ]()
    // TBD: can we avoid the any? Own AnyEntry protocol doesn't give much?
  
  // a hack to support type erased values
  mutating func _setAny<T>(_ key: Any.Type, _ newValue: T) {
    values[ObjectIdentifier(key)] = newValue
  }
  
  public subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
    set {
      values[ObjectIdentifier(key)] = newValue
    }
    get {
      // values[SizeCategoryKey.self] => ContentSizeCategory
      guard let value = values[ObjectIdentifier(key)] else {
        return K.defaultValue
      }
      guard let typedValue = value as? K.Value else {
        assertionFailure("unexpected typed value: \(value)")
        return K.defaultValue
      }
      return typedValue
    }
  }
}


extension TreeStateContext {
  
  func dumpEnvironmentStack(_ title: String = "The current environments:") {
    print(title)
    for (i, environment) in environmentStack.enumerated().reversed() {
      let indent = String(repeating: "  ", count: i)
      
      if environment.values.isEmpty {
        print("[\(i)]\(indent): EMPTY")
        continue
      }
      
      print("[\(i)]\(indent):")
      for (oid, v ) in environment.values {
        print("   \(indent)   \(oid.shortRawPointerString):", v)
      }
    }
    print("---")
  }
}
