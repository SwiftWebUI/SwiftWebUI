//
//  TreeBuildingContext.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 06.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// The source code is distributed under the terms of the Bad Code License.
// You are forbidden from distributing software containing the code to end
// users, because it is bad.

public final class TreeStateContext: CustomStringConvertible {
  // Easily the most important class in the whole setup. And not just because
  // it is the sole class ;-)
  //
  // This has grown quite a bit. Maybe split up.
  
  var currentBuilder = HTMLTreeBuilder.default
  
  // MARK: - Element IDs
  
  private(set) var currentElementID = ElementID.rootElementID
  
  @discardableResult
  func pushElementID(_ eid: ElementID) -> ElementID {
    let last = currentElementID
    currentElementID = eid
    return last
  }
  
  func appendContentElementIDComponent() {
    currentElementID.appendContentElementIDComponent()
  }

  func appendElementIDComponent<T: Hashable>(_ id: T) {
    currentElementID.appendElementIDComponent(id)
  }
  func appendZeroElementIDComponent() {
    currentElementID.appendZeroElementIDComponent()
  }
  func incrementLastElementIDComponent() {
    currentElementID.incrementLastElementIDComponent()
  }
  func deleteLastElementIDComponent() {
    currentElementID.deleteLastElementIDComponent()
  }
  
  
  // MARK: - Component States
  
  var elementIDToState = [ ElementID : StateHolder ]()
    // not private for testing
  
  func stateHolderForElementID<V: View>(_ elementID: ElementID,
                                        in view: inout V)
       -> StateHolder
  {
    // inout to avoid copying
    if let holder = elementIDToState[elementID] { return holder }
    let holder = StateHolder.makeInitialHolderForView(&view, with: elementID,
                                                      in: self)
    elementIDToState[elementID] = holder
    return holder
  }
  
  
  // MARK: - Environment
  
  #if DEBUG && true
    var environmentStack = [ EnvironmentValues.empty ] {
      didSet {
        if debugEnvironmentChanges {
          dumpEnvironmentStack(
            "environment changed: #\(environmentStack.count)")
        }
      }
    }
  #else
    var environmentStack = [ EnvironmentValues.empty ]
  #endif

  public init() {}
  
  var environment : EnvironmentValues {
    return environmentStack.last ?? EnvironmentValues.empty
  }

  
  // MARK: - Traits
  
  var traitStacks = [ AnyHashable: [ TraitValues ] ]()

  
  // MARK: - Component Stack
  // WO is more complicated here because bindings are two way (push up and down)

  // we could simulate appear/disappear using those
  private var awakeComponents = [ _DynamicElementNode ]()
  private var componentStack  = [ _DynamicElementNode ]()
  
  var component: _DynamicElementNode? {
    return componentStack.last
  }
  #if false // don't need those?
  var parentComponent: _DynamicElementNode? {
    return componentStack.count > 1
           ? componentStack[componentStack.count - 2]
           : nil
  }
  #endif

  func _awakeComponent(_ component: _DynamicElementNode) {
    guard !awakeComponents.contains(where: { $0 === component }) else { return }
    awakeComponents.append(component)
    // TODO: emit didAppear? (or we add some didAwake)
  }
  
  func enterComponent<V: View>(_ component: DynamicElementNode<V>) {
    // Inout to avoid copying, not for actual modification
    if debugComponentScopes {
      print("ENTER:", V.self, component.elementID.webID,
            "parent:",
            (componentStack.last?.viewType).flatMap(String.init(describing:))
              ?? "-")
    }

    let stateHolder = stateHolderForElementID(component.elementID,
                                              in: &component.view)
    stateHolder.assignStateSlotsInView(&component.view)

    DynamicViewPropertyHelpers.update(&component.view, in: self)

    componentStack.append(component)
    _awakeComponent(component)
  }
  func leaveComponent<V: View>(_ component: DynamicElementNode<V>) {
    assert(!componentStack.isEmpty)
    if debugComponentScopes {
      print("LEAVE:", V.self, component.elementID.webID)
    }

    let stateHolder = stateHolderForElementID(component.elementID,
                                              in: &component.view)
    stateHolder.clearStateSlotsInView(&component.view)
    
    guard !componentStack.isEmpty else { return }
    componentStack.removeLast()
  }

  
  // MARK: - Invalidation
  
  private(set) var invalidComponentIDs = Set<ElementID>()
    // TODO: better data structure. We probably get many invalidations in a
    //       single run, but we also want to support nesting here.
  
  func clearAllInvalidComponentsPriorTreeRebuild() {
    invalidComponentIDs.removeAll()
  }
  
  func processInvalidComponent(with id: ElementID) -> Bool {
    return invalidComponentIDs.remove(id) != nil
  }
  
  func invalidateComponentWithID(_ id: ElementID) {
    guard !invalidComponentIDs.contains(id) else { return }

    if debugInvalidation {
      print("INVALIDATE:", id.webID)
    }

    for invalidID in invalidComponentIDs {
      if id.hasPrefix(invalidID) {
        if debugInvalidation {
          print("  INVALIDATE:", id, "parent already invalid:", invalidID)
        }
        return
      }
      if invalidID.hasPrefix(id) {
        if debugInvalidation {
          print("  INVALIDATE:", id, "drop child:", invalidID)
        }
        invalidComponentIDs.remove(invalidID)
      }
    }
    invalidComponentIDs.insert(id)
    
    if debugInvalidation {
      print("INVALIDATE:", id, "invalid:",
            invalidComponentIDs.map { $0.description }.joined(separator: ","))
    }
  }
  
  
  // MARK: - Tracking Tree Deletions
  
  func nodeGotDeleted(_ id: ElementID) {
    if debugComponentScopes {
      print("NODE DELETED:", id.webID)
    }
    for stateID in elementIDToState.keys {
      if stateID.hasPrefix(id) {
        elementIDToState.removeValue(forKey: stateID)
      }
    }
  }
  
  
  // MARK: - Layout Modifiers
  
  // This is a little crappy, but well.
  // TBD: Can we use traits for this? Maybe not worth the extra Any overhead?
  
  var layoutInfoStack = [ LocalLayoutInfo() ]
  var localLayoutInfo : LocalLayoutInfo {
    set {
      assert(!layoutInfoStack.isEmpty)
      guard !layoutInfoStack.isEmpty else { return }
      layoutInfoStack[layoutInfoStack.count - 1] = newValue
    }
    get {
      return layoutInfoStack.last ?? LocalLayoutInfo()
    }
  }
  
  func enterLayoutContext() {
    layoutInfoStack.append(LocalLayoutInfo())
  }
  func leaveLayoutContext() {
    layoutInfoStack.removeLast()
    assert(!layoutInfoStack.isEmpty) // always have one
  }
  
  
  // MARK: - Value Change Overrides
  
  // Those are to not emit value changes for things we know the client DOM
  // already has. Otherwise we could drop content the user types while we
  // are processing the change event.
  
  private var ignoredValueChanges = [ ElementID : String ]()
  
  func ignoreValueChange(_ value: String, for elementID: ElementID) {
    ignoredValueChanges[elementID] = value
  }
  func shouldIgnoreValueChange(_ value: String, for elementID: ElementID)
       -> Bool
  {
    return ignoredValueChanges[elementID] == value
  }
  
  func clearDiffingStates() {
    ignoredValueChanges.removeAll()
  }
  
  
  // MARK: - Description
  
  public var description: String {
    var ms = "<Ctx: currentID=\(currentElementID.webID)"
    ms += " env=\(environment)"
    ms += " states=\(elementIDToState)"
    ms += ">"
    return ms
  }
}

struct LocalLayoutInfo: Equatable, CustomStringConvertible {
  
  var width  : Length? = nil
  var height : Length? = nil
  
  var isEmpty: Bool {
    return width == nil && height == nil
  }
  
  var description: String {
    switch ( width, height ) {
      case (.some(let width), .some(let height)):
        return "<LocalLayout: \(width)x\(height)>"
      case (.some(let width), .none):  return "<LocalLayout: w=\(width)>"
      case (.none, .some(let height)): return "<LocalLayout: h\(height)>"
      case ( .none, .none ):           return "<LocalLayout/>"
    }
  }
}
