//
//  DynamicViewContent.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 11.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol DynamicViewContent : View {
  // repeatable content
  
  associatedtype Data : Collection
  
  var data: Self.Data { get }
}

// Note: This has stuff like onDelete, onMove, onInsert,
//       which return `_TraitWritingModifier`s.
