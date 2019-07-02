//
//  Text.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 05.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import class Foundation.Formatter
import class Foundation.Bundle

public struct Text : Equatable, View {
  public typealias Body = Never

  public init(verbatim content: String) {
    self.runs = [ .verbatim(content) ]
  }
  public init<S>(_ content: S) where S : StringProtocol {
    self.init(verbatim: String(content))
  }

  public init(_ key: LocalizedStringKey,
              tableName: String? = nil, bundle: Bundle? = nil,
              comment: StaticString? = nil)
  {
    // FIXME: So technically this has to be bound to the session like in
    //        SwiftObjects, because the language setting in a web app is
    //        per user!
    //        So we'd have to preserve the localized key as such in the Run.
    let bundle = bundle ?? Bundle.main
    let s = bundle.localizedString(forKey: key.value, value: key.value,
                                   table: tableName)
    self.init(verbatim: s)
  }
  
  public init(_ value: Any?, formatter: Formatter) {
    // TBD: we could support attributed strings!
    #if os(Linux)
      self.init(verbatim: formatter.string(for: value as Any) ?? "??")
    #else
      self.init(verbatim: formatter.string(for: value) ?? "??")
    #endif
  }
  
  private init(runs: [ Run ]) {
    self.runs = runs
  }
  
  let runs : [ Run ]
  
  enum Run : Equatable, CustomStringConvertible {
    // TODO: Add LocalizedString variants
    case verbatim(String)
    case styled(String, [ Modifier ])

    init(content: String, modifiers: [ Modifier ]) {
      if modifiers.isEmpty { self = .verbatim(content) }
      else                 { self = .styled(content, modifiers) }
    }

    var contentString : String {
      switch self {
        case .verbatim(let s):  return s
        case .styled(let s, _): return s
      }
    }
    
    var description: String {
      switch self {
        case .verbatim(let s): return "Run('\(s)')"
        case .styled(let s, let modifiers):
          let mods = modifiers.map({ $0.description }).joined(separator: ",")
          return "Run<\(mods)>('\(s)')"
      }
    }
  }
  
  var contentString : String {
    return runs.map({ $0.contentString }).joined()
  }
  
  enum Modifier : Equatable, CustomStringConvertible {
    case bold, italic
    case color(Color?)
    case font(Font?)

    var description: String {
      switch self {
        case .bold:                return "bold"
        case .italic:              return "italic"
        case .color(.none):        return "color-reset"
        case .color(.some(let v)): return "color(\(v.cssStringValue))"
        case .font(.none):         return "font-reset"
        case .font(.some(let v)):  return "font(\(v))"
      }
    }
    
    var isColor : Bool {
      switch self {
        case .color: return true
        default:     return false
      }
    }
    var isFont : Bool {
      switch self {
        case .font: return true
        default:    return false
      }
    }
  }
  
  // TODO: +(lhs,rhs): smart addition of Text w/ runs
  
  static func +(lhs: Text, rhs: Text) -> Text {
    // FIXME: Make smarter, combine runs
    return Text(runs: lhs.runs + rhs.runs)
  }
  static func +(lhs: Text, rhs: String) -> Text {
    return Text(runs: lhs.runs + [ .verbatim(rhs) ])
  }
}

extension Text: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}

extension Array where Element == Text.Modifier {
  mutating func enrichingTextModifiers(from context: TreeStateContext) {
    let env = context.environment
    if self.isEmpty {
      self.reserveCapacity(2)
      if let v = env.font            { append(.font(v))  }
      if let v = env.foregroundColor { append(.color(v)) }
      return
    }
    
    if !contains(where: { $0.isFont }), let v = env.font {
      append(.font(v))
    }
    if !contains(where: { $0.isColor }), let v = env.foregroundColor {
      append(.color(v))
    }
  }
}

public extension Text {
  
  private func adding(_ modifier: Modifier) -> Text {
    return Text(runs: runs.map { run in
      switch run {
        case .verbatim(let s):
          return Run(content: s, modifiers: [ modifier ])
        
        case .styled(let s, let modifiers):
          if modifiers.contains(modifier) { return run }
          return Run(content: s, modifiers: modifiers + [ modifier ])
      }
    })
  }
  func bold()                -> Text { return adding(.bold) }
  func italic()              -> Text { return adding(.italic) }
  func color(_ color: Color) -> Text { return adding(.color(color)) }
  func font (_ font: Font?)  -> Text { return adding(.font(font))   }

}
