//
//  ElementID.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 13.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

fileprivate let rootElementIDComponent    = "/"
fileprivate let contentElementIDComponent = "_"
fileprivate let noElementIDComponent      = NoElementID()

fileprivate struct NoElementID: Hashable {
}

public struct ElementID: Hashable, CustomStringConvertible {
  // By keeping them as `Hashable`, we can preserve the identity of keys in
  // ForEach.
  // It makes rendering them to the web clumsy though (though this could be
  // worked around using some map $web-id-slot => real-id).
  
  private var components : [ AnyHashable ]
  
  var count: Int { return components.count }
  
  static let rootElementID = ElementID(components: [ rootElementIDComponent ])
  static let noElementID   = ElementID(components: [ noElementIDComponent] )
  
  var webID: String {
    assert(!components.isEmpty, "asking for web ID of empty element-id?")
    return components.map { $0.webID }.joined(separator: ".")
  }

  // MARK: - Modifying the ElementID
  
  @inline(__always)
  mutating func deleteLastElementIDComponent() {
    components.removeLast()
  }
  
  @inline(__always)
  mutating func appendContentElementIDComponent() {
    components.append(contentElementIDComponent)
  }
  
  @inline(__always)
  mutating func appendElementIDComponent<T: Hashable>(_ id: T) {
    components.append(AnyHashable(id))
  }
  @inline(__always)
  mutating func appendElementIDComponent(_ id: AnyHashable) {
    components.append(id)
  }

  @inline(__always)
  mutating func appendZeroElementIDComponent() {
    components.append(0)
  }
  
  mutating func incrementLastElementIDComponent() {
    assert(!components.isEmpty,
           "attempt to increment empty elementID \(self)")
    guard !components.isEmpty else { return }
    
    let lastIndex = components.count - 1
    assert(components[lastIndex] is Int)
    guard let lastValue = components[components.count - 1].base as? Int else {
      assertionFailure("attempt to increment non-int ID")
      return
    }
    
    components[lastIndex] = lastValue + 1
  }

  func appendingElementIDComponent<T: Hashable>(_ id: T) -> ElementID {
    var eid = self
    eid.appendElementIDComponent(id)
    return eid
  }
  func appendingElementIDComponent(_ id: AnyHashable) -> ElementID {
    var eid = self
    eid.appendElementIDComponent(id)
    return eid
  }

  
  // MARK: - Matching
  
  func hasPrefix(_ other: ElementID) -> Bool {
    guard other.components.count <= self.components.count else { return false }
    for i in 0..<other.components.count {
      guard other.components[i] == components[i] else { return false }
    }
    return true
  }
  
  
  // MARK: - Description
  
  public var description: String {
    return webID
  }
}

protocol WebRepresentableIdentifier {

  var webID: String { get }

}

extension Int: WebRepresentableIdentifier {
  var webID: String { return String(self) }
}

extension String: WebRepresentableIdentifier {
  var webID: String {
    // FIXME
    // lame-o. Not sure what is best here.
    if !self.contains(".") { return self }
    return self.replacingOccurrences(of: ".", with: "_")
  }
}

extension AnyHashable: WebRepresentableIdentifier {
  var webID: String {
    // TBD: make this the other way around ;-) Only if makeWebID can't find
    //      anything, we should check the map.
    if let webID = elementIDComponentToWebID[self] { return webID }
    return ElementID.makeWebID(for: base)
  }
}


import class NIOConcurrencyHelpers.Atomic

// A super lame workaround to deal with arbitrary hash values. Its size is
// unbounded ;-)
// OKayish for testing, but warn the user to use `WebRepresentableIdentifier`s.
fileprivate var elementIDComponentToWebID = [ AnyHashable: String ]()
  // TODO: make threadsafe
fileprivate var xIDSequence = Atomic(value: Int.random(in: 0...31011973))
fileprivate let xIDPrefix   = "X"

extension ElementID { // WebID

  @inline(__always)
  static func makeWebID(for id: String) -> String { return id }
  @inline(__always)
  static func makeWebID(for id: Int) -> String { return String(id) }
  
  @inline(__always)
  static func makeWebID<T: WebRepresentableIdentifier>(for id: T) -> String {
    return id.webID
  }

  #if false // FIXME: this breaks stuff
  static func makeWebID<T: CaseIterable & Identifiable>(for id: T) -> String {
    return "\(id)" // enum case
  }

  static func makeWebID<T: Identifiable>(for value: T) -> String {
    return makeWebID(for: value.id)
  }
  #endif
  
  static func makeWebID(for id: AnyHashable) -> String {
    if let webID = elementIDComponentToWebID[id] { return webID }
    let sv = xIDSequence.add(1)
    let webID = xIDPrefix + String(sv, radix: 16, uppercase: true)
    elementIDComponentToWebID[id] = webID
    print("WARN: registering custom webID for non-standard ID:",
          id, "=>", webID)
    return webID
  }
  
  static func makeWebID<T: Hashable>(for id: T) -> String {
    // FIXME: This is sometimes picked instead of makeWebID<Int>?! Which is why
    //        we have this cast in here. Hm.
    // Same for CaseIterable.
    if let webID = (id as? WebRepresentableIdentifier)?.webID {
      return webID
    }

    let s = makeWebID(for: AnyHashable(id))
    return s
  }
  
  @inline(__always)
  static func makeWebID(for id: Any) -> String {
    if let webID = (id as? WebRepresentableIdentifier)?.webID {
      return webID
    }
    let s = String(describing: id).webID
    print("WARN: generating custom webID for Any:", id, "=>", s)
    return s
  }

  func isContainedInWebID(_ webID: [ String ]) -> Bool {
    // Note: IDs always grow down the tree ... (not in WO, but in our case we
    //       rely on this, aka custom-IDs are not allowed to avoid having to
    //       traverse the whole thing).
    guard webID.count >= components.count else { return false }
    for i in 0..<components.count {
      guard components[i].webID == webID[i] else { return false }
    }
    return true
  }
  
  static func ==(lhs: ElementID, rhs: [ String ]) -> Bool {
    guard lhs.components.count == rhs.count else { return false }
    for i in 0..<rhs.count {
      guard lhs.components[i].webID == rhs[i] else { return false }
    }
    return true
  }
  
  static func ==<T>(lhs: ElementID, rhs: T) -> Bool
           where T: RandomAccessCollection, T.Element == String
  {
    guard lhs.components.count == rhs.count else { return false }
    for ( i, webComponentID ) in rhs.enumerated() {
      guard lhs.components[i].webID == webComponentID else { return false }
    }
    return true
  }

}
