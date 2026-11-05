//
//  Trait.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 19.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// What is a trait? Chris:
// "A trait is like a preference, it travels upwards to the container of a
//  view". But not higher.
// I think the difference to an environment key is that traits never change
// ("dynamically").

public protocol Trait {
  associatedtype Key : Hashable
  static var key : Key { get }
}
public extension Trait {
  static var key : ObjectIdentifier { return ObjectIdentifier(Self.self) }
}

final class TraitValues {
  // This is quite hacky and inefficient. I suspect traits in the real thing
  // are set directly on the ("graph") nodes.
  
  var values = [ ( elementID: ElementID, traitKey: AnyHashable, value: Any ) ]()
    // we want to preserve the order
  
  private func index<T: Trait>(of trait: T.Type, for elementID: ElementID)
               -> Int?
  {
    let oid = AnyHashable(T.self.key)
    return values.firstIndex(where: { entry in
      entry.elementID == elementID && entry.traitKey == oid
    })
  }

  func set<T: Trait>(_ trait: T, for elementID: ElementID) {
    let oid = AnyHashable(T.self.key)
    
    if let idx = index(of: T.self, for: elementID) {
      values[idx] = ( elementID, oid, trait )
    }
    else {
      values.append( ( elementID, oid, trait ) )
    }
  }
}

extension TreeStateContext {
  // Yes yes, this imp is not great.
  
  func setTrait<T: Trait>(_ trait: T) {
    let oid = AnyHashable(T.self.key)
    guard let values = traitStacks[oid]?.last else {
      print("WARN: no receiver for trait:", trait)
      return
    }
    if debugTraits {
      print("TR: set trait:", trait, "for:", currentElementID.webID)
    }
    values.set(trait, for: currentElementID)
  }
  
  func collectingTraits<T1: Trait, R>(_ t1: T1.Type, _ execute: () -> R)
       -> ( result: R, values: [ ( ElementID, T1? ) ] )
  {
    let oid1   = AnyHashable(T1.self.key)
    let values = TraitValues()
    
    if traitStacks[oid1] != nil { traitStacks[oid1]!.append(values) }
    else  { traitStacks[oid1] = [ values ] }
    defer { traitStacks[oid1]?.removeLast() }
    
    let traits = ( execute(), values.values.compactMap { entry in
      return ( entry.elementID, entry.value as? T1 )
    })
    
    if debugTraits {
      print("TR: collected traits:")
      for ( eid, t1 ) in traits.1 {
        if let t1 = t1 { print("  \(eid.webID):", t1)  }
        else           { print("  \(eid.webID) EMPTY") }
      }
      print("--")
    }

    return traits
  }
  
  func collectingTraits<T1: Trait, T2: Trait, R>(_ t1: T1.Type, _ t2: T2.Type,
                                                 _ execute: () -> R)
       -> ( result: R, values: [ ( ElementID, T1?, T2? ) ] )
  {
    // Also returns empty elements, unlike the single value thing!
    let oid1   = AnyHashable(T1.self.key)
    let oid2   = AnyHashable(T2.self.key)
    let values = TraitValues()
    
    if traitStacks[oid1] != nil { traitStacks[oid1]!.append(values) }
    else  { traitStacks[oid1] = [ values ] }
    defer { traitStacks[oid1]?.removeLast() }
    if traitStacks[oid2] != nil { traitStacks[oid2]!.append(values) }
    else  { traitStacks[oid2] = [ values ] }
    defer { traitStacks[oid2]?.removeLast() }
    
    let v = execute()
    
    var traits = [ ( ElementID, T1?, T2? ) ]()
    var eidToSlot = [ ElementID: Int ]()
    
    for ( elementID, traitKey, value ) in values.values {
      let slot : Int = {
        if let idx = eidToSlot[elementID] { return idx }
        let newSlot = traits.count
        eidToSlot[elementID] = newSlot
        traits.append( ( elementID, nil, nil ) )
        return newSlot
      }()
      
      let old = traits[slot]
      if traitKey == oid1 {
        traits[slot] = ( elementID, value as? T1, old.2)
      }
      else { // oid2
        assert(traitKey == oid2)
        traits[slot] = ( elementID, old.1, value as? T2)
      }
    }
    
    if debugTraits {
      print("TR: collected traits:")
      for ( eid, t1, t2 ) in traits {
        switch ( t1, t2 ) {
          case ( .some(let t1), .some(let t2) ):
            print("  \(eid.webID):", t1, t2)
          case ( .some(let t1), .none ):
            print("  \(eid.webID):", t1, "-")
          case ( .none, .some(let t2) ):
            print("  \(eid.webID):", "-", t2)
          case ( .none, .none ):
            print("  \(eid.webID) EMPTY")
        }
      }
      print("--")
    }

    return ( v, traits )
  }
}
