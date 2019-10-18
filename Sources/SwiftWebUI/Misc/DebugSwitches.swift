//
//  DebugSwitches.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 25.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if DEBUG
  let debugComponentScopes    = false
  let debugInvalidation       = false
  let debugEnvironmentChanges = false
  let debugRequestPhases      = false
  let debugDumpTrees          = false
  let debugTraits             = false
#else
  let debugComponentScopes    = false
  let debugInvalidation       = false
  let debugEnvironmentChanges = false
  let debugRequestPhases      = false
  let debugDumpTrees          = false
  let debugTraits             = false
#endif



extension ObservableObject { // can't extend AnyObject ...
  
  var pointerDescription: String {
    return ObjectIdentifier(self).shortRawPointerString
  }
  
}

extension ObjectIdentifier {
  
  var rawPointerString: String {
    let s = String(describing: self)
    return s.hasPrefix("ObjectIdentifier(")
         ? String(s.dropFirst(17).dropLast(1))
         : s
  }
  var shortRawPointerString: String {
    rawPointerString.replacingOccurrences(of: "0x0000000", with: "0x")
  }
}
