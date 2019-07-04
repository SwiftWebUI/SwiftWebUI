//
//  NIOSessionIDGeneration.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 19.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import struct Foundation.UUID

extension NIOHostingSession {
  static func createSessionID() -> String {
    // As discussed in https://github.com/swiftwebui/SwiftWebUI/issues/4
    return UUID().uuidString
  }
}
