//
//  Unsplash.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 25.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

extension Image {
  
  public init(_ source: UnsplashSource, label: Text? = nil) {
    self.storage = .url(source.url, label: label)
  }
  
  public static func unsplash(scope : UnsplashSource.Scope = .none,
                              time  : UnsplashSource.Time  = .all,
                              size  : UXSize = UXSize(width: 640, height: 480),
                              terms : [ String ]) -> Image
  {
    return Image(UnsplashSource(
      scope: scope, time: time,
      size:
      UnsplashSource.Size(width: Int(size.width), height: Int(size.height)),
      terms: terms)
    )
  }
  public static func unsplash(scope : UnsplashSource.Scope = .none,
                              time  : UnsplashSource.Time  = .all,
                              size  : UXSize = UXSize(width: 640, height: 480),
                              _ terms : String...) -> Image
  {
    return unsplash(scope: scope, time: time, size: size, terms: terms)
  }
}
