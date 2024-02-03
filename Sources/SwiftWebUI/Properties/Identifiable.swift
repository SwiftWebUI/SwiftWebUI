//
//  Identifiable.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 06.06.19.
//  Copyright © 2019-2020 Helge Heß. All rights reserved.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  // macOS 10.15, iOS 13 have Identifiable (and we require those version for
  // `some` anyways.
#else // FIXME: which Swift
  public protocol Identifiable {
    
    associatedtype ID: Hashable
    
    var id : Self.ID { get }
  }

  public extension Identifiable where Self: CaseIterable {
    var id : Self { return self }
  }

  public extension Identifiable where Self: AnyObject {
    // Note: This is not so great for Web content because OIDs are not webIDs.
    var id: ObjectIdentifier { return ObjectIdentifier(self) }
  }
#endif // Linux

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
