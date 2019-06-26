//
//  DynamicViewProperty.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol _DynamicViewPropertyType {
  
  static func _updateInstance(at location: UnsafeMutableRawPointer)
  
}

public protocol DynamicViewProperty : _DynamicViewPropertyType {
  // E.g. implemented by State
  // 2019-06-12: I don't currently know how to implement that. We can reflect
  //             on the DynamicViewProperties of a View quite easily using
  //             Mirror, but we can't call a mutating function on the original
  //             location.
  //             They probably do some modifying reflection here (but that
  //             needs to make sure the view itself is stored in a `var`,
  //             (fine, just as part of the ComponentNode?).
  //      Asked: https://forums.swift.org/t/dynamicviewproperty/25627
  
  // Called before body() is executed, after updating link variables.
  // This can access `DynamicViewPropertyContext.current`
  mutating func update()
  
}

public extension DynamicViewProperty {

  static func _updateInstance(at location: UnsafeMutableRawPointer) {
    let typedPtr = location.assumingMemoryBound(to: Self.self)
    typedPtr.pointee.update()
  }

}

public extension DynamicViewProperty {
  mutating func update() {}
}

extension Binding : DynamicViewProperty {} // TBD

enum DynamicViewPropertyHelpers {
  static var currentContext : TreeStateContext? { // TODO: make thread local
    willSet {
      // This is not a stack
      assert(currentContext == nil || newValue == nil)
    }
  }

  static func update<V: View>(_ view: inout V, in context: TreeStateContext) {
    guard case .dynamic(let props) = view.lookupTypeInfo() else { return }
    
    currentContext = context
    props.forEach { $0.updateInView(&view) }
    currentContext = nil
  }
}
