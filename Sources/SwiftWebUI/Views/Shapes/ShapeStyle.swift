//
//  ShapeStyle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 24.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol ShapeStyle {
}
extension ShapeStyle {
  public typealias Member = StaticMember<Self>
}

extension Color: ShapeStyle {
}

extension ImagePaint: ShapeStyle {
  
}

#if false // for those??
extension StaticMember where Base : ShapeStyle {
  public static var color : Color.Member {
    return Color.Member(base: Color.black)
  }
}
#endif

public struct ForegroundStyle: ShapeStyle {
  // No idea what this is. Just a type for matching?
}
