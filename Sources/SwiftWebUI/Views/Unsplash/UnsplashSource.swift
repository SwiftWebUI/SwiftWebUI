//
//  UnsplashSource.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 25.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import struct Foundation.URL
import struct Foundation.URLComponents

/// Generates URLs for placeholder photos.
///
/// This used to target the Unsplash Source API (source.unsplash.com), which
/// Unsplash shut down. It now targets Lorem Picsum (picsum.photos), which
/// serves Unsplash photos. Picsum has no search, so the `terms` are used as
/// a seed, which yields a stable photo per set of terms. `scope` and `time`
/// are kept for API compatibility, but have no effect anymore.
public struct UnsplashSource {
  
  public enum Scope {
    case none
    case featured
    case user(String)
    case collection(String)
    
    var pathComponents: [ String ] {
      switch self {
        case .none:              return []
        case .featured:          return [ "featured"      ]
        case .user(let user):    return [ "user", user    ]
        case .collection(let v): return [ "collection", v ]
      }
    }
  }
  
  public enum Time {
    case all, daily, weekly
    
    var pathComponent: String {
      switch self {
        case .all:    return ""
        case .daily:  return "daily"
        case .weekly: return "weekly"
      }
    }
  }
  
  public struct Size {
    public var width  : Int = 640
    public var height : Int = 480
    
    var pathComponent: String { return "\(width)x\(height)" }
  }
  
  public var scope : Scope
  public var time  : Time
  public var size  : Size?
  public var terms : [ String ]
  
  public var url: URL {
    // https://picsum.photos/seed/{seed}/{width}/{height}
    let size = self.size ?? Size()
    var pathComponents = [ String ]()
    if !terms.isEmpty {
      let seed = terms.map { $0.lowercased() }.joined(separator: "-")
      pathComponents += [ "seed", seed ]
    }
    pathComponents += [ String(size.width), String(size.height) ]
    
    var url = URLComponents()
    url.scheme = "https"
    url.host   = "picsum.photos"
    url.path   = "/" + pathComponents.map {
      $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? $0
    }.joined(separator: "/")
    return url.url!
  }
}

