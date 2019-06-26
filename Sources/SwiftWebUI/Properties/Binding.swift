//
//  Binding.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@propertyDelegate public struct Binding<Value> {
  // TBD: kinda like WOAssociation?
  
  // TBD: transaction, what about that?
  
  public var value : Value {
    nonmutating set { setter(newValue) }
    get { return getter() }
  }
  
  private var getter : () -> Value
  private var setter : ( Value ) -> Void
  
  public init(getValue: @escaping ()        -> Value,
              setValue: @escaping ( Value ) -> Void)
  {
    self.getter = getValue
    self.setter = setValue
  }
  
  /// Creates a binding with an immutable `value`.
  public static func constant(_ value: Value) -> Binding<Value> {
    return Binding<Value>(getValue: { return value },
                          setValue: { _ in
                            assertionFailure("cannot set constant")
                          })
  }
  
  internal static func readOnly(_ getValue: @escaping () -> Value)
                       -> Binding<Value>
  {
    return Binding<Value>(getValue: getValue,
                          setValue: { _ in
                            assertionFailure("cannot set r/o value \(self)")
                          })
  }
}

public extension Binding {
  
  // TBD: What about the Hashable wrapper, why is that necessary?
  
  // Binding<Int> => Binding<Int?>
  init<BaseValue>(_ base: Binding<BaseValue>) where Value == BaseValue? {
    // TBD: Is this thinking right?
    var isOptional = false // captured and shared by closures
    self.init(
      getValue: { return isOptional ? nil : base.value },
      setValue: { newValue in
         if let value = newValue { isOptional = false; base.setter(value) }
         else { isOptional = true }
      }
    )
  }
  
  init?(_ base: Binding<Value?>) {
    // TBD: does this actually make sense?
    guard var value = base.value else { return nil }
    self.init(
      getValue: { return value },
      setValue: { newValue in value = newValue }
    )
  }
  
}

// MARK: - Support specific bound types

extension Binding where Value: SetAlgebra, Value.Element: Hashable {
  public func contains(_ element: Value.Element) -> Binding<Bool> {
    return Binding<Bool>.readOnly { self.value.contains(element) }
  }
}

extension Binding where Value: RawRepresentable {
  public var rawValue: Binding<Value.RawValue> {
    return Binding<Value.RawValue>.readOnly { self.value.rawValue }
  }
}

extension Binding where Value: CaseIterable, Value: Equatable {
  public var caseIndex: Binding<Value.AllCases.Index> {
    return Binding<Value.AllCases.Index>.readOnly {
      return Value.allCases.firstIndex(of: self.value)!
    }
  }
}

extension Binding: Sequence
            where Value: MutableCollection, Value.Index: Hashable
{
  public typealias Element = Binding<Value.Element>
  
  public typealias Iterator = IndexingIterator<Binding<Value>>
  
  /// A sequence that represents a contiguous subrange of the collection's
  /// elements.
  ///
  /// This associated type appears as a requirement in the `Sequence`
  /// protocol, but it is restated here with stricter constraints. In a
  /// collection, the subsequence should also conform to `Collection`.
  public typealias SubSequence = Slice<Binding<Value>>
}

extension Binding: Collection
            where Value: MutableCollection, Value.Index: Hashable
{
  public typealias Index   = Value.Index
  public typealias Indices = Value.Indices
  
  public var startIndex : Value.Index   { return value.startIndex }
  public var endIndex   : Value.Index   { return value.endIndex   }
  public var indices    : Value.Indices { return value.indices    }

  public func index(after i: Value.Index) -> Value.Index {
    return value.index(after: i)
  }
  public func formIndex(after i: inout Value.Index) {
    return value.formIndex(after: &i)
  }
  
  public subscript(position: Value.Index) -> Binding<Value.Element> {
    return .readOnly { self.value[position] }
  }
}

extension Binding: BidirectionalCollection
            where Value: BidirectionalCollection,
                  Value: MutableCollection,
                  Value.Index: Hashable
{
  public func index(before i: Value.Index) -> Value.Index {
    return value.index(before: i)
  }
  public func formIndex(before i: inout Value.Index) {
    return value.formIndex(before: &i)
  }
}
