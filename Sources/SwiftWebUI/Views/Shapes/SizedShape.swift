//
//  SizedShape.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public extension Shape {
  
  func size(_ size: UXSize) -> SizedShape<Self> {
    return SizedShape(shape: self, size: size)
  }
  
  func size(width: Length, height: Length) -> SizedShape<Self> {
    // Hmmmm, this takes a Length. So UXSize should probably be based around
    // lengths? CSS would probably deal with that quite right.
    switch ( width, height ) {
      case ( .pixels(let w), .pixels(let h) ):
        return SizedShape(shape: self, size: UXSize(width: w, height: h))
      default:
        fatalError("unsupported Length unit")
    }
  }
}

public struct SizedShape<S: Shape>: Shape, Equatable {
  
  public var shape : S
  public var size  : UXSize
  
  public func path(in rect: UXRect) -> Path {
    // No idea whether this is correct.
    return shape.path(in: UXRect(origin: rect.origin, size: size))
  }
}
