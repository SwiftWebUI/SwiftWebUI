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

#else // !canImport(CoreGraphics)

  public typealias UXFloat = Float

  public struct UXPoint: Equatable {
    public var x      : UXFloat
    public var y      : UXFloat
    
    public init(x: Int, y: Int) {
      self.x = UXFloat(x)
      self.y = UXFloat(y)
    }
  }
  public struct UXSize: Equatable {
    public var width  : UXFloat
    public var height : UXFloat

    public init(width: Int, height: Int) {
      self.width  = UXFloat(width)
      self.height = UXFloat(height)
    }
  }
  public struct UXRect: Equatable {
    public var origin : UXPoint
    public var size   : UXSize

    public init(origin: UXPoint, size: UXSize) {
      self.origin = origin
      self.size   = size
    }

    public init(x: Int, y: Int, width: Int, height: Int) {
      origin = .init(x: x, y: y)
      size   = .init(width: width, height: height)
    }

    public func insetBy(dx: UXFloat, dy: UXFloat) -> UXRect {
      var r = self
      r.origin.x    += dx
      r.origin.y    += dy
      r.size.width  -= dx * 2
      r.size.height -= dy * 2
      return r
    }
  }
#endif // !canImport(CoreGraphics)
