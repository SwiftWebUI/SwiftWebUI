//
//  SelectionManager.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol SelectionManager {
  
  associatedtype SelectionValue : Hashable
  
  mutating func select  (_ value: SelectionValue)
  mutating func deselect(_ value: SelectionValue)
  
  func isSelected(_ value: SelectionValue) -> Bool
  
  var allowsMultipleSelection: Bool { get }
}

public extension SelectionManager {
  var allowsMultipleSelection: Bool { return true }
}

extension SelectionManager {
  
  mutating func toggle(_ value: SelectionValue) {
    if isSelected(value) { deselect(value) }
    else                 { select  (value) }
  }
  
}

extension Set: SelectionManager {
  public typealias SelectionValue = Element
  public mutating func select  (_ value: Element) { insert(value) }
  public mutating func deselect(_ value: Element) { remove(value) }
  public func isSelected(_ value: Element) -> Bool { contains(value) }
}

extension Never: SelectionManager {
  public mutating func select  (_ value: Never)  {}
  public mutating func deselect(_ value: Never)  {}
  public func isSelected(_ value: Never) -> Bool {}
}

extension Optional: SelectionManager where Wrapped : Hashable {
  // TBD: Is this the proper implementation?
  
  public typealias SelectionValue = Wrapped
  
  public mutating func select  (_ value: Wrapped) { self = .some(value) }
  public mutating func deselect(_ value: Wrapped) { self = .none }
  
  public func isSelected(_ value: Wrapped) -> Bool {
    switch self {
      case .none:             return false
      case .some(let stored): return stored == value
    }
  }
  public var allowsMultipleSelection: Bool { return false }
}
