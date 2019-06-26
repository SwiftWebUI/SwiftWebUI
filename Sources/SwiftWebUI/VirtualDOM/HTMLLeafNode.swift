//
//  File.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol HTMLLeafNode: HTMLTreeNode {
}

extension HTMLLeafNode {
  
  func rewrite(using rewriter: ( HTMLTreeNode ) -> RewriteAction)
       -> HTMLTreeNode
  {
    switch rewriter(self) {
      case .replaceAndReturn(let newNode): return newNode
      case .recurse: return self
    }
  }
  
  func takeValue(_ webID: [ String ], value: String,
                 in context: TreeStateContext) throws
  {
    throw WebInvocationError.inactiveElement(webID)
  }
  func invoke(_ webID: [ String ], in context: TreeStateContext) throws {
    throw WebInvocationError.inactiveElement(webID)
  }

  var children: [ HTMLTreeNode ] { return [] }
  func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<\(self)/>")
  }
}
