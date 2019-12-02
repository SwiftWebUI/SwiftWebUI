//
//  ObservableObject.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 06.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if USE_COMBINE
import Combine
#elseif USE_COMBINEX
import CombineX
#elseif USE_OPEN_COMBINE
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
