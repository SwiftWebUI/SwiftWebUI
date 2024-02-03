//
//  Identifiable.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 06.06.19.
//  Copyright © 2019-2024 Helge Heß. All rights reserved.
//

extension Int: Identifiable {
  public var id: Int { return self }
}

public struct IdentifierValuePair<ID: Hashable, Value>: Identifiable {
  
  public let id    : ID
  public let value : Value
  
  public init(id: ID, value: Value) {
    self.id    = id
    self.value = value
  }
  
  public var identifiedValue: Value { return value }
}
public extension Collection {

  func identified<ID>(by getID: KeyPath<Self.Element, ID>)
       -> [ IdentifierValuePair<ID, Self.Element> ] where ID : Hashable
  {
    return map { IdentifierValuePair(id: $0[keyPath: getID], value: $0) }
  }
}
