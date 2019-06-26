//
//  ImagePaint.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct ImagePaint: Equatable {
  
  public var image      : Image
  public var sourceRect : UXRect
  public var scale      : Length
  
  public init(image: Image,
              sourceRect: UXRect = UXRect(x: 0, y: 0, width: 1, height: 1),
              scale: Length = 1)
  {
    self.image      = image
    self.sourceRect = sourceRect
    self.scale      = scale
  }
}
