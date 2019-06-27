//
//  Button.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 15.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct Button<Label: View>: View {

  public typealias Body = Label

  public var body : Self.Body { return label }
  
  let action : () -> Void
  let label  : Label
  
  public init(_ action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
    self.action = action
    self.label  = label()
  }
  
  init(action: @escaping () -> Void, label: Label) {
    self.action = action
    self.label  = label
  }
}

extension Button where Label == ButtonStyleLabel {
  init<T: View>(action: @escaping () -> Void, label: T) {
    self.action = action
    self.label  = ButtonStyleLabel(label)
  }
}

extension HTMLTreeBuilder {
  
  func buildTree<Label: View>(for view: Button<Label>,
                              in context: TreeStateContext) -> HTMLTreeNode
  {
    let concreteButtonView = context.environment.buttonStyle.body(
      configuration: Button<ButtonStyleLabel>(
        action: view.action, label: view.label
      )
    )
    return context.currentBuilder.buildTree(for: concreteButtonView,
                                            in: context)
  }
}

extension Button: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}


public protocol ButtonStyle {
  
  associatedtype Body : View
  
  typealias Label  = ButtonStyleLabel
  typealias Member = StaticMember<Self>
  
  func body(configuration: Button<Label>) -> Body
  
}

public struct ButtonStyleLabel : View {
  public typealias Body = Never
  
  private var bodyBuild : ( TreeStateContext ) -> HTMLTreeNode
  
  init<V: View>(_ view: V) {
    self.bodyBuild = { context in
      return context.currentBuilder.buildTree(for: view, in: context)
    }
  }
}

extension ButtonStyleLabel: TreeBuildingView {
  
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return bodyBuild(context)
  }
}

public typealias DefaultButtonStyle = SUIButtonStyle

extension StaticMember where Base : ButtonStyle {
  public static var `default` : DefaultButtonStyle.Member {
    return .init(base: .init()) // TBD
  }
}
enum ButtonStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyButtonStyle {
    return AnyButtonStyle(DefaultButtonStyle())
  }
}

public extension EnvironmentValues {
  
  var buttonStyle: AnyButtonStyle {
    set { self[ButtonStyleEnvironmentKey.self] = newValue }
    get { self[ButtonStyleEnvironmentKey.self] }
  }
}

public extension View {
  
  func buttonStyle<S: ButtonStyle>(_ style: S.Member)
       -> EnvironmentView<AnyButtonStyle>
  {
    return environment(\.buttonStyle, AnyButtonStyle(style.base))
  }
}

public struct AnyButtonStyle: ButtonStyle {
  
  public typealias Label  = ButtonStyleLabel
  public typealias Member = StaticMember<Self>

  private var bodyBuild : ( Button<Label> ) -> AnyView
  
  init<S: ButtonStyle>(_ style: S) {
    self.bodyBuild = { configuration in
      return AnyView(style.body(configuration: configuration))
    }
  }

  public func body(configuration: Button<Label>) -> AnyView {
    return self.bodyBuild(configuration)
  }
}
