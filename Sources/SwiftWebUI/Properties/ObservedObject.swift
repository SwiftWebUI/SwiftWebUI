//
//  ObservedObject.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if canImport(Combine)
  import Combine
#elseif canImport(OpenCombine)
  import OpenCombine
#endif

@propertyWrapper
public struct ObservedObject<O: ObservableObject>: _StateType {

  var _slot : StateHolder.StateEntryPointer = nil
  private var _value: O
  
  public var wrappedValue : O {
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
  
  public init(wrappedValue: O) {
    self._value = wrappedValue
  }
  
  // MARK: - Exposed Values
  
  @dynamicMemberLookup // TIL
  public struct Wrapper {
    
    let value: O
    
    public subscript<V>(dynamicMember keyPath: ReferenceWritableKeyPath<O, V>)
           -> Binding<V>
    {
      return value[keyPath]
    }
  }
  
  public var projectedValue: Wrapper {
    return Wrapper(value: wrappedValue)
  }
  // TBD: public var storageValue: Wrapper { get }

  
  // MARK: - StateHolder Storage
  
  struct StateValueBox: StateValue, CustomStringConvertible {
    var value        : O
    var subscription : AnyCancellable
    var description  : String { return "<BoundObj: \(value)>" }
  }
  
  static func _initialValueBox(at   location : UnsafeRawPointer,
                               for elementID : ElementID,
                               in    context : TreeStateContext) -> StateValue
  {
    let typedPtr = location.assumingMemoryBound(to: Self.self)
    let subscription = typedPtr.pointee._value.didChange.sink {
      [unowned context] _ in // Fishy, maybe ordering sensitive? Rather weak it?
      context.invalidateComponentWithID(elementID)
    }
    return StateValueBox(value: typedPtr.pointee._value,
                         subscription: AnyCancellable(subscription))
  }
}

#if DEBUG && false
fileprivate class MyStore: ObservableObject {
  static let global = MyStore()
  var didChange = PassthroughSubject<Void, Never>()
  var i = 5 { didSet { didChange.send(()) } }
}
fileprivate struct MyView : View {
  @ObservedObject var store = MyStore.global
  var body: some View {
    Text("Blub \(store.i)")
  }
}
#endif
