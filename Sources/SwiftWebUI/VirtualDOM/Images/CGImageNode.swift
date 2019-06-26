//
//  CGImage.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if canImport(CoreGraphics)

import struct Foundation.Data
import class  CoreGraphics.CGImage
import ImageIO

fileprivate let defaultImageDataCapacity = 32000 // TBD

extension CGImage {
  
  // TBD: should that have scale data already?
  func generateData(type: String) -> Data? {
    guard let data = CFDataCreateMutable(nil, defaultImageDataCapacity) else {
      return nil
    }
    guard let destination = CGImageDestinationCreateWithData(
      data, type as CFString, 1, nil
    ) else { return nil }
    
    CGImageDestinationAddImage(destination, self, nil)
    guard CGImageDestinationFinalize(destination) else {
      print("could not render CGImage ...")
      return nil
    }
    return data as Data
  }
  
}

#endif // canImport(CoreGraphics)
