//
//  State.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@propertyDelegate
public struct State<Value>: BindingConvertible, _StateType {
  // Sample:
  //   struct MyView : View {
  //     @State private var zoomed : Bool = false
  // becomes:
  //   struct MyView : View {
  // Note: this is exposed as `$zoomed`!
  //     private var $__delegate_storage_$_zoomed : State<Bool>
  //                 = .init(initialValue: false)
  //     private var zoomed : Bool {
  //       set { state.zoomed.value = newValue }
  //       get { return state.zoomed.value }
  
  var _slot  : StateHolder.StateEntryPointer = nil
  var _value : Value // FIXME
  
  public init(initialValue: Value) {
    self._value = initialValue
  }
  
  public var value : Value {
    get {
      assert(_slot != nil, "you cannot access @State outside of `body`")
      guard let slot = _slot else { return _value }
      guard let box  = slot.pointee.value as? StateValueBox else {
        assertionFailure("@State value is pointing to a different box type!")
        return _value
      }
      return box.value
    }
    nonmutating set {
      assert(_slot != nil, "you cannot access @State outside of `body`")
      guard let slot = _slot else { return }
      slot.pointee.value = StateValueBox(value: newValue)
      slot.pointee.holder.invalidateComponent()
    }
  }
  
  public var delegateValue: Binding<Value> {
    // This exposes the "$state" property as a `Binding<Value>` instead of
    // `State<Value>`.
    return binding
  }

  // TODO DynamicViewProperty.update
  public mutating func update() {
    // Note: We cannot use the self-ptr as the slot-id, because we create
    //       new View instances at new locations. We essentially need the
    //       offset.
    // Summary: The State itself does not have sufficient info to fill itself.
    // TBD: within the `body`, can the state update itself?? I.e. does it need
    //      to peek into the storage or not?
    #if DEBUG && false
      print("called:", #function, "on:", self, "my ptr:", UnsafePointer(&self))
    #endif
    _value = value // TBD: not used anyways?
  }
  
  public var binding: Binding<Value> {
    return Binding(getValue: { return self.value },
                   setValue: { newValue in self.value = newValue })
  }
  
  // MARK: - StateHolder Storage
  
  struct StateValueBox: StateValue, CustomStringConvertible {
    var value : Value
    var description: String { return "<Box: \(value)>" }
  }
  
  static func _initialValueBox(at   location : UnsafeRawPointer,
                               for elementID : ElementID,
                               in    context : TreeStateContext) -> StateValue
  {
    let typedPtr = location.assumingMemoryBound(to: Self.self)
    return StateValueBox(value: typedPtr.pointee._value)
  }
}

public extension State where Value : ExpressibleByNilLiteral {
  
  init() { self.init(initialValue: nil) }
  
}
