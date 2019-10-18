//
//  ObservableObject.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 06.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// FIXME: Combine requires 10.15, maybe provide a simple alternative
#if canImport(Combine)
  import Combine
#elseif canImport(OpenCombine)
  import OpenCombine
#endif

public protocol ObservableObject: AnyObject, DynamicViewProperty, Identifiable {
  
  associatedtype PublisherType : Publisher
                   where Self.PublisherType.Failure == Never
  
  var didChange: Self.PublisherType { get }

}

public extension ObservableObject {
  
  subscript<T>(keyPath: ReferenceWritableKeyPath<Self, T>) -> Binding<T> {
    return Binding(getValue: { return self[keyPath: keyPath] },
                   setValue: { self[keyPath: keyPath] = $0   })
  }
}
