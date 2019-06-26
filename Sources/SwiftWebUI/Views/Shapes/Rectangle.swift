//
//  Rectangle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@available(*, unavailable)
public struct Rectangle: InsettableShape {

  public var body: some View {
    return ShapeView(shape: self, style: ForegroundStyle())
  }

  public func path(in rect: UXRect) -> Path {
    return Path(rect)
  }
  public func inset(by amount: Length) -> some Shape {
    return Inset(amount: amount)
  }
  
  public struct Inset: Shape {

    public var amount : Length
    
    public var body: some View {
      return ShapeView(shape: self, style: ForegroundStyle())
    }
    
    public func path(in rect: UXRect) -> Path {
      return Path(rect.insetBy(amount))
    }
  }
}
