//
//  TextField.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import class Foundation.Formatter

public struct TextField: View {

  public typealias Body = Never
  
  let value            : Binding<String>
  let placeholder      : Text?
  let isPassword       : Bool
  let onEditingChanged : (( Bool ) -> Void)?
  let onCommit         : (()       -> Void)?

  public init(_ text           : Binding<String>,
              placeholder      : Text? = nil,
              onEditingChanged : (( Bool ) -> Void)? = nil,
              onCommit         : (()       -> Void)? = nil)
  {
    self.value            = text
    self.placeholder      = placeholder
    self.isPassword       = false
    self.onEditingChanged = onEditingChanged
    self.onCommit         = onCommit
  }
  public init<T>(_ binding        : Binding<T>,
                 placeholder      : Text? = nil,
                 formatter        : Formatter,
                 onEditingChanged : (( Bool ) -> Void)? = nil,
                 onCommit         : (()       -> Void)? = nil)
  {
    self.init(binding.formatter(formatter), placeholder: placeholder,
              onEditingChanged: onEditingChanged, onCommit: onCommit)
  }
  
  init(secureText text: Binding<String>, placeholder: Text? = nil,
       onCommit: (() -> Void)? = nil)
  {
    self.value            = text
    self.placeholder      = placeholder
    self.isPassword       = true
    self.onEditingChanged = nil
    self.onCommit         = onCommit
  }
}

extension HTMLTreeBuilder {
  
  func buildTree(for view: TextField, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    let textFieldStyle = context.environment.textFieldStyle
    let concreteTextFieldView = textFieldStyle.body(configuration: view)
    return context.currentBuilder.buildTree(for: concreteTextFieldView,
                                            in: context)
  }
}

extension TextField: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}

public protocol TextFieldStyle {

  associatedtype Body : View

  typealias Member = StaticMember<Self>
  
  func body(configuration: TextField) -> Body
  
}

public typealias DefaultTextFieldStyle = SUITextFieldStyle

extension StaticMember where Base : TextFieldStyle {
  public static var `default` : DefaultTextFieldStyle.Member {
    return .init(base: .init())
  }
}

enum TextFieldStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyTextFieldStyle {
    return AnyTextFieldStyle(DefaultTextFieldStyle())
  }
}

public extension EnvironmentValues {
  
  var textFieldStyle: AnyTextFieldStyle {
    set { self[TextFieldStyleEnvironmentKey.self] = newValue }
    get { self[TextFieldStyleEnvironmentKey.self] }
  }
}

public extension View {
  
  func textFieldStyle<S: TextFieldStyle>(_ style: S.Member)
       -> EnvironmentView<AnyTextFieldStyle>
  {
    return environment(\.textFieldStyle, AnyTextFieldStyle(style.base))
  }
}

public struct AnyTextFieldStyle: TextFieldStyle {
  
  public typealias Member = StaticMember<Self>

  private var bodyBuild : ( TextField ) -> AnyView
  
  init<S: TextFieldStyle>(_ style: S) {
    self.bodyBuild = { configuration in
      return AnyView(style.body(configuration: configuration))
    }
  }

  public func body(configuration: TextField) -> AnyView {
    return self.bodyBuild(configuration)
  }
}
