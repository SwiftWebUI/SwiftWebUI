//
//  RoundedRectangle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

@available(*, unavailable)
public struct RoundedRectangle: InsettableShape {
  
  public var cornerRadius: Length
  
  public var body: some View {
    return ShapeView(shape: self, style: ForegroundStyle())
  }
  
  public func path(in rect: UXRect) -> Path {
    return Path(roundedRect: rect, cornerRadius: cornerRadius)
  }
  public func inset(by amount: Length) -> some Shape {
    return Inset(cornerRadius: cornerRadius, amount: amount)
  }
  
  public struct Inset: Shape {
    
    public var cornerRadius : Length
    public var amount       : Length
    
    public var body: some View {
      return ShapeView(shape: self, style: ForegroundStyle())
    }
    
    public func path(in rect: UXRect) -> Path {
      return Path(roundedRect: rect.insetBy(amount), cornerRadius: cornerRadius)
    }
  }
}
