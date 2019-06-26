//
//  EnvironmentObject.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 21.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if canImport(Combine)
import Combine
// Uses `.sink` and `AnyCancellable` on the BindableObject
#endif

@propertyDelegate
public struct EnvironmentObject<O: BindableObject>: _StateType {
  // TODO: This is pretty much a copy of the @BindableObject with only minor
  //       differences.
  
  var _slot : StateHolder.StateEntryPointer = nil
  
  public init() {} // has no own value
  
  public var value : O {
    get {
      guard let slot = _slot else {
        fatalError("you cannot access @EnvironmentObject outside of `body`")
      }
      guard let box = slot.pointee.value as? StateValueBox else {
        fatalError(
          "@EnvironmentObject value is pointing to a different box type!")
      }
      return box.value
    }
    nonmutating set {
      assert(_slot != nil, "you cannot access @State outside of `body`")
      guard let slot = _slot else { return }
      
      let oldBox = slot.pointee.value as? StateValueBox
      if oldBox?.value === newValue { return } // same
      
      // OK, got a new object assigned, update
      // TBD: Should this ever happen? I guess it can as part of body closures.

      let elementID = slot.pointee.holder.id
      let context   = slot.pointee.holder.context
      let subscription = newValue.didChange.sink {
        [unowned context] _ in
        context.invalidateComponentWithID(elementID)
      }
      
      slot.pointee.value =
        StateValueBox(value: newValue,
                      subscription: AnyCancellable(subscription))
      slot.pointee.holder.invalidateComponent()
    }
  }
  
  // MARK: - StateHolder Storage
  
  struct StateValueBox: StateValue, CustomStringConvertible {
    var value        : O
    var subscription : AnyCancellable
    var description  : String { "<EnvObj: \(value)>" }
  }
  
  static func _initialValueBox(at   location : UnsafeRawPointer,
                               for elementID : ElementID,
                               in    context : TreeStateContext) -> StateValue
  {
    guard let initialValue = context.environment[EnvironmentObjectKey<O>.self]
     else
    {
      let viewName : String? = {
        guard let component = context.component else { return nil }
        return String(describing: component.viewType)
      }()
      print(
        """

        ERROR: You are trying to access an @EnvironmentObject object:

          of type: \(O.self)
          in view: \(viewName ?? "??")

        But you didn't push an object using `.environmentObject(yourObject)`
        in your enclosing views `body`. Srz, but that won't work!
        
        """
      )
      context.dumpEnvironmentStack()
      
      fatalError("missing environment object in environment! \(O.self)")
    }
    
    let subscription = initialValue.didChange.sink {
      [unowned context] _ in // Fishy, maybe ordering sensitive? Rather weak it?
      context.invalidateComponentWithID(elementID)
    }
    return StateValueBox(value: initialValue,
                         subscription: AnyCancellable(subscription))
  }

}
