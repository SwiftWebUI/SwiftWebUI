//
//  UnsplashSource.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 25.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import struct Foundation.URL
import struct Foundation.URLComponents

// https://source.unsplash.com
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
    var pathComponents = scope.pathComponents + [ time.pathComponent ]
    if let size = size { pathComponents.append(size.pathComponent) }
    
    var url = URLComponents()
    url.scheme = "https"
    url.host   = "source.unsplash.com"
    url.path   = "/" + pathComponents.map {
      $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? $0
    }.joined(separator: "/")
    
    url.query = terms.map {
      $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0
    }.joined(separator: ",")

    return url.url!
  }
}

