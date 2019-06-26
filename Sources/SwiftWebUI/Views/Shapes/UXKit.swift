//
//  UXKit.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if canImport(CoreGraphics)

  import typealias CoreGraphics.CGFloat
  import struct CoreGraphics.CGPoint
  import struct CoreGraphics.CGSize
  import struct CoreGraphics.CGRect

  public typealias UXFloat = CoreGraphics.CGFloat
  public typealias UXPoint = CoreGraphics.CGPoint
  public typealias UXSize  = CoreGraphics.CGSize
  public typealias UXRect  = CoreGraphics.CGRect

#else

  public typealias UXFloat = Float

  public struct UXPoint: Equatable {
    public var x      : UXFloat
    public var y      : UXFloat
  }
  public struct UXSize: Equatable {
    public var width  : UXFloat
    public var height : UXFloat
  }
  public struct UXRect: Equatable {
    public var origin : CGPoint
    public var size   : CGSize
  }
#endif
