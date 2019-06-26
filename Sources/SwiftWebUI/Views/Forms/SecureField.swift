//
//  SecureField.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct SecureField: View {
  
  public let body : TextField
  
  public init(_ text: Binding<String>, placeholder: Text? = nil,
              onCommit: (()       -> Void)? = nil)
  {
    body = TextField(secureText: text, placeholder: placeholder,
                     onCommit: onCommit)
  }
  
}
