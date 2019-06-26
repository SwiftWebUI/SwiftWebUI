//
//  WOHelpers.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 08.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

extension String {
  
  mutating func appendContentString(_ s: String) {
    append(s)
  }
  mutating func appendContentHTMLString(_ s: String) {
    append(s.htmlEscaped)
  }
  mutating func appendContentHTMLAttributeValue(_ s: String) {
    append(s.htmlEscaped)
  }

  mutating func appendAttribute(_ name: String, _ value: String?) {
    append(" ")
    appendContentString(name) // TODO: escape properly!
    if let value = value {
      append("=\"")
      appendContentHTMLAttributeValue(value)
      append("\"")
    }
  }
}

fileprivate let escapeMap : [ Character : String ] = [
  "<" : "&lt;", ">": "&gt;", "&": "&amp;", "\"": "&quot;"
]
extension Character {
  var htmlEscaped : String {
    return escapeMap[self] ?? "\(self)"
  }
}
extension StringProtocol {
  var htmlEscaped : String {
    return map { escapeMap[$0] ?? String($0) }.reduce("", +)
  }
}
