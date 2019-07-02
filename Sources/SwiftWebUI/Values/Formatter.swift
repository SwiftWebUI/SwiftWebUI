//
//  Formatter.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import class Foundation.Formatter
import class Foundation.NSString

extension Binding {
  
  func formatter(_ formatter: Formatter) -> Binding<String> {
    return Binding<String>(
      getValue: {
           formatter.editingString(for: self.wrappedValue)
        ?? formatter.string       (for: self.wrappedValue)
        ?? ""
      },
      setValue: { s in
        var obj   : AnyObject?
        var error : NSString?

        guard formatter.getObjectValue(&obj, for: s,
                                       errorDescription: &error) else
        {
          // Note: if that happens, we are our of sync!
          print("WARN: failed to format input string:", s, type(of: self),
                "error:", error ?? "?")
          return
        }

        guard let v = obj as? Value else {
          print("WARN: failed to convert formatted input string:",
                s, type(of: self), String(describing: obj))
          return
        }
        
        self.wrappedValue = v
      }
    )
  }
  
}

#if DEBUG
extension Binding where Value == String {
  
  func formatter(_ formatter: Formatter) -> Binding<String> {
    return Binding<String>(
      getValue: {
        let v = self.wrappedValue
        return formatter.editingString(for: v)
            ?? formatter.string       (for: v)
            ?? "FmtErr<" + v + ">"
      },
      setValue: { s in
        var obj   : AnyObject?
        var error : NSString?

        guard formatter.getObjectValue(&obj, for: s,
                                       errorDescription: &error) else
        {
          // Note: if that happens, we are our of sync!
          print("WARN: failed to format input string:", s, type(of: self),
                "error:", error ?? "?")
          return
        }
        
        if let v = obj as? String {
          self.wrappedValue = v
        }
        else if let obj = obj {
          self.wrappedValue = "FmtErr<\(obj)>"
        }
        else {
          self.wrappedValue = "FmtErr<None>"
        }
      }
    )
  }
}
#endif
