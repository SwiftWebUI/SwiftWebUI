//
//  View.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol View {
  
  associatedtype Body : View
  
  var body : Self.Body { get }

}

//support for optional Views, mainly for @ViewBuilder convenience
extension Optional : View where Wrapped : View {
    public var body: EmptyView {
        EmptyView()
    }
}
