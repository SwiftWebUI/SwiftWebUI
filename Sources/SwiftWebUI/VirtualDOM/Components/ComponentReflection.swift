//
//  ComponentReflection.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 13.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

enum ComponentTypeInfo: Equatable {
  
  case `static`
  case `dynamic`(dynamicProperties: [ DynamicPropertyInfo ])
  
  var statePropertyCount: Int { // TBD: cache?
    guard case .dynamic(let props) = self else { return 0 }
    var currentState = 0
    for prop in props {
      guard prop.stateInstance != nil else { continue }
      currentState += 1
    }
    return currentState
  }
  
  struct DynamicPropertyInfo: Equatable {
    
    let rawName       : String
    let name          : String
    let offset        : Int
    let typeInstance  : _DynamicViewPropertyType.Type
    let stateInstance : _StateType.Type?

    func mutablePointerIntoView<T: View>(_ view: inout T)
         -> UnsafeMutableRawPointer
    {
      // Note: We do not really need the `T` here.
      let viewPtr    = UnsafeMutablePointer(&view)
      let rawViewPtr = UnsafeMutableRawPointer(viewPtr)
      let rawPropPtr = rawViewPtr.advanced(by: offset)
      return rawPropPtr
    }
    
    func updateInView<T: View>(_ view: inout T) {
      // Note: We do not really need the `T` here.
      let rawPropPtr = mutablePointerIntoView(&view)
      typeInstance._updateInstance(at: rawPropPtr)
    }
    
    static func ==(lhs: DynamicPropertyInfo, rhs: DynamicPropertyInfo)
                -> Bool
    {
      guard lhs.offset        == rhs.offset        else { return false }
      guard lhs.name          == rhs.name          else { return false }
      guard lhs.typeInstance  == rhs.typeInstance  else { return false }
      guard lhs.stateInstance == rhs.stateInstance else { return false }
      return true
    }
    
  }
}

// FIXME: Those need to be locked or thread-local eventually. Works because
//        we run single threaded ATM.
fileprivate var componentTypeCache : [ ObjectIdentifier : ComponentTypeInfo ]
                                   = [:]

extension View {
  
  func lookupTypeInfo() -> ComponentTypeInfo {
    // FIXME: static func ;-)
    let typeOID = ObjectIdentifier(type(of: self))
    
    if let ti = componentTypeCache[typeOID] { return ti }
    
    let newType = ComponentTypeInfo(reflecting: Self.self) ?? .static
    componentTypeCache[typeOID] = newType
    return newType
  }
  
}

import func Runtime.typeInfo

extension ComponentTypeInfo {
  
  fileprivate init?<T: View>(reflecting viewType: T.Type) {
    guard let structInfo = try? Runtime.typeInfo(of: viewType) else {
      print("failed to reflect on View:", viewType)
      assertionFailure("failed to reflect on View \(viewType)")
      return nil
    }
    guard structInfo.kind == .struct else {
      print("Only structs allowed as View:", viewType)
      assertionFailure("currently only supporting structs for Views")
      return nil
    }
    
    let dynamicProperties : [ ComponentTypeInfo.DynamicPropertyInfo ]
                          = structInfo.properties.compactMap {
      propInfo in
                            
      guard let dynamicType =
                  propInfo.type as? _DynamicViewPropertyType.Type else {
        return nil
      }
                            
      let stateInstance = propInfo.type as? _StateType.Type
      
      let rawName : String = propInfo.name
      let cleanedName : String = {
        if rawName.hasPrefix(magicDelegateStoragePrefix) {
          return String(rawName.dropFirst(magicDelegateStoragePrefix.count))
        }
        // This happens for Binding and Environment
        #if false
          assert(!rawName.hasPrefix("$"),
                 "another special property name: \(rawName)")
        #else
          if rawName.hasPrefix("$") {
            return String(rawName.dropFirst())
          }
        #endif
        return rawName
      }()
      
      let info = DynamicPropertyInfo(rawName       : rawName,
                                     name          : cleanedName,
                                     offset        : propInfo.offset,
                                     typeInstance  : dynamicType,
                                     stateInstance : stateInstance)
      return info
    }
    self = dynamicProperties.isEmpty
      ? .static
      : .dynamic(dynamicProperties: dynamicProperties)
  }
  
}

fileprivate let magicDelegateStoragePrefix = "$__delegate_storage_$_"
