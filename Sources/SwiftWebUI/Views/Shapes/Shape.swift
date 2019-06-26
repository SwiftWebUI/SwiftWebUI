//
//  Shape.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol Shape: View, Equatable {
  func path(in rect: UXRect) -> Path
}

public protocol InsettableShape: Shape {
  associatedtype InsetShape : Shape
  func inset(by amount: Length) -> InsetShape
}
