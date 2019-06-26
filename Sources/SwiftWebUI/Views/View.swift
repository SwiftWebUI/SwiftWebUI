//
//  View.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol View {
  
  associatedtype Body : View
  
  var body : Self.Body { get }

}
