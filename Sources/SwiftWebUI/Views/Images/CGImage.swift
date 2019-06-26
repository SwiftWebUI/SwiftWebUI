//
//  CGImage.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if canImport(CoreGraphics)

import class  CoreGraphics.CGImage

public extension Image {
  
  init(_ cgImage: CGImage, scale: Length? = nil, label: Text? = nil) {
    self.storage = .cgImage(cgImage, scale: scale, label: label)
  }

}

#endif // canImport(CoreGraphics)
