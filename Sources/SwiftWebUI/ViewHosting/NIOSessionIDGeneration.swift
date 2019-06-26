//
//  NIOSessionIDGeneration.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 19.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import class  NIOConcurrencyHelpers.Atomic
import struct Foundation.Date
import func   SwiftHash.MD5

extension NIOHostingSession {
  
  // MARK: - Session ID
  
  private static var snIdCounter = Atomic(value: 0)
  
  static func createSessionID() -> String {
    // FIXME: The security desaster.
    //
    // TODO: better place in app object to allow for 'weird' IDs ;-), like
    //       using a session per basic-auth user
    // FIXME: dangerous non-sense, use properly secured SID :-)
    let now = Int(Date().timeIntervalSince1970)
    let cnt = snIdCounter.add(Int.random(in: 0...1337 /* not so much */))
    let ran = String(Int.random(in: Int.min..<Int.max), radix: 16)
    let baseString = "\txyyzSID\n\(now)\t\(cnt)\t\(ran)"
    return SwiftHash.MD5(baseString)
  }
}
