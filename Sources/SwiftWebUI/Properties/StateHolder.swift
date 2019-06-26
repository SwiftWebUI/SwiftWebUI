//
//  StateHolder.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

protocol StateValue {}

protocol _StateType : DynamicViewProperty {
  
  var _slot : StateHolder.StateEntryPointer { get set }

  static func _initialValueBox(at   location : UnsafeRawPointer,
                               for elementID : ElementID,
                               in    context : TreeStateContext) -> StateValue
}


final class StateHolder: CustomStringConvertible {
  // We could make this generic over V: View for easier debugging, but that
  // makes other stuff harder.
  
  typealias StateEntryPointer = UnsafeMutablePointer<StateEntry>?
  
  struct StateEntry: CustomStringConvertible {
    unowned let holder: StateHolder
    var value : StateValue
    
    var description: String { return "<StateEntry: \(value)>" }
  }

  unowned let context : TreeStateContext
  let         type    : Any.Type
  let         id      : ElementID
  private var values  : UnsafeMutableBufferPointer<StateEntry>?
    // Yeah, this could be just a binary blob with the proper strides for
    // much better performance. But well POitRoaE ;-)
  
  private init<V: View>(context: TreeStateContext, type: V.Type,
                        elementID: ElementID)
  {
    self.context = context
    self.type    = type
    self.id      = elementID
  }
  deinit {
    if let values = values {
      // TBD: don't we have to deinitialize?
      values.deallocate()
    }
  }
  
  func invalidateComponent() {
    context.invalidateComponentWithID(id)
  }
  
  static func makeInitialHolderForView<V: View>(_ view: inout V,
                                                with elementID: ElementID,
                                                in context: TreeStateContext)
              -> StateHolder
  {
    let holder = StateHolder(context: context, type: V.self,
                             elementID: elementID)
    let typeInfo = view.lookupTypeInfo()
    guard case .dynamic(let props) = typeInfo else {
      return holder
    }
    
    holder.values = .allocate(capacity: typeInfo.statePropertyCount)
    _ = holder.values!.initialize(from: props.compactMap { prop in
      guard let stateType = prop.stateInstance else { return nil }
      
      let rawPropPtr = prop.mutablePointerIntoView(&view)
      let value = stateType._initialValueBox(at: rawPropPtr, for: elementID,
                                             in: context)
      
      let entry = StateEntry(holder: holder, value: value)
      return entry
    })
    return holder
  }
  
  func assignStateSlotsInView<T: View>(_ view: inout T) {
    guard case .dynamic(let props) = view.lookupTypeInfo() else {
      context.nodeGotDeleted(id)
      assertionFailure("static view w/ dynamic slot")
      return
    }
    
    if ObjectIdentifier(T.self) != ObjectIdentifier(type) {
      // This drops the old state holder
      if debugComponentScopes {
        print("state type mismatch:\n",
              "  new:", T.self, "\n",
              "  old:", type, "\n")
      }
      context.nodeGotDeleted(id)
      
      let newStateHolder = context.stateHolderForElementID(id, in: &view)
      newStateHolder.assignStateSlotsInView(&view)
      return
    }
    
    assert(values != nil, "slots not setup yet?! \(self)")
    
    var currentState = 0
    for prop in props {
      guard prop.stateInstance != nil else { continue }
      assert(currentState < values!.count)
      
      let stateEntryPointer = values!.baseAddress!.advanced(by: currentState)
      
      let rawPropPtr = prop.mutablePointerIntoView(&view)
      let slotPtr = rawPropPtr.assumingMemoryBound(to: StateEntryPointer.self)
      slotPtr.pointee = stateEntryPointer

      currentState += 1
    }
  }

  func clearStateSlotsInView<T: View>(_ view: inout T) {
    guard case .dynamic(let props) = view.lookupTypeInfo() else { return }
    
    assert(values != nil, "slots not setup yet?! \(self)")
    
    var currentState = 0
    for prop in props {
      guard prop.stateInstance != nil else { continue }
      assert(currentState < values!.count)
      
      let rawPropPtr = prop.mutablePointerIntoView(&view)
      let slotPtr = rawPropPtr.assumingMemoryBound(to: StateEntryPointer.self)
      slotPtr.pointee = nil
      
      currentState += 1
    }
  }
  
  var description: String {
    var ms = "<StateHolder[\(id)]:"
    // ms += " ctx=\(ObjectIdentifier(context))"
    
    if let values = values, !values.isEmpty {
      for ( i, entry ) in values.enumerated() {
        ms += " [\(i)]"
        ms += String(describing: entry.value)
      }
      ms += values.map { $0.description }.joined(separator: ",")
    }
    else { ms += " NO-VALUES" }
    ms += ">"
    return ms
  }
}
