//
//  SystemImage.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// Icons we know we have outlines for in SemanticUI
fileprivate let suiOutlineNames : Set<String> = [
  "circle",
  "envelope",
  // "caret" - those do not seem to have outlines
]

fileprivate let sfNameToSUI : [ String : String ] = [
  "questionmark"  : "question",
  "power"         : "power off",
  "arrowtriangle" : "caret"
]

public extension Image {

  init(systemName: String) {
    // Semantic UI does such:
    //   "phone volume"
    //   "question circle"
    // i.e. the Font Awesome naming:
    //   https://fontawesome.com/icons?d=gallery&q=circle
    //
    // SF Symbols does such:
    //   questionmark.circle
    //
    // We could also use an extra Emoji thing.
    
    let sfClasses : Set<String> = Set(
      systemName.split(separator: ".").map(String.init)
    )
    
    var suiClasses : Set<String> = Set(
      sfClasses.map { sfName in return sfNameToSUI[sfName] ?? sfName }
    )

    if suiClasses.contains("cart") {
      suiClasses.insert("shopping")
      // no minus ...
    }
    

    // circle.fill => circle
    // circle      => circle outline
    if suiClasses.contains("fill") {
      suiClasses.remove("fill")
    }
    else if !suiClasses.intersection(suiOutlineNames).isEmpty {
      suiClasses.insert("outline")
      suiClasses.insert("alternate") // ¯\_(ツ)_/¯
    }
    
    self.storage = .icon(class: suiClasses.sorted().joined(separator: " "))
  }
  
}
