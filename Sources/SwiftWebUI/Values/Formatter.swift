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
           formatter.editingString(for: self.value)
        ?? formatter.string       (for: self.value)
        ?? ""
      },
      setValue: { s in
        #if os(Linux) // getObjectValue is internal on Linux
          print("PORT ME:", #function) // FIXME
          let obj = s
        #else
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
        #endif

        guard let v = obj as? Value else {
          print("WARN: failed to convert formatted input string:",
                s, type(of: self), String(describing: obj))
          return
        }
        
        self.value = v
      }
    )
  }
  
}

#if DEBUG && !os(Linux)
extension Binding where Value == String {
  
  func formatter(_ formatter: Formatter) -> Binding<String> {
    return Binding<String>(
      getValue: {
        let v = self.value
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
          self.value = v
        }
        else if let obj = obj {
          self.value = "FmtErr<\(obj)>"
        }
        else {
          self.value = "FmtErr<None>"
        }
      }
    )
  }
}
#endif
