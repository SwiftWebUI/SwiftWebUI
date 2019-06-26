//
//  Toggle.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 20.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// FIXME: The real Toggle defers the rendering to the "ToggleStyle"

public struct Toggle<Label: View>: View {
  // Note: This is just a hub which defers the rendering to a ToggleStyle

  public typealias Body = Label

  public var body : Self.Body { return label }
  
  let isOn  : Binding<Bool>
  let label : Label
  
  public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
    self.isOn  = isOn
    self.label = label()
  }
  init(isOn: Binding<Bool>, _ label: Label) {
    self.isOn  = isOn
    self.label = label
  }
}

extension HTMLTreeBuilder {
  
  func buildTree<Label: View>(for view: Toggle<Label>,
                              in context: TreeStateContext) -> HTMLTreeNode
  {
    let style           = context.environment.toggleStyle
    let typeErasedLabel = ToggleStyleLabel(view.label)
    let concreteView    = style.body(
      configuration: Toggle<ToggleStyleLabel>(isOn: view.isOn, typeErasedLabel)
    )
    
    return context.currentBuilder.buildTree(for: concreteView, in: context)
  }
}

extension Toggle: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}


// MARK: - Style

public protocol ToggleStyle {

  associatedtype Body : View

  typealias Label  = ToggleStyleLabel
  typealias Member = StaticMember<Self>
  
  func body(configuration: Toggle<Label>) -> Body
  
}


// MARK: - Type Erased Label

public struct ToggleStyleLabel : View {
  public typealias Body = Never

  fileprivate var bodyBuild : ( TreeStateContext ) -> HTMLTreeNode
  
  init<V: View>(_ view: V) {
    self.bodyBuild = { context in
      return context.currentBuilder.buildTree(for: view, in: context)
    }
  }
}

extension HTMLTreeBuilder {
  func buildTree(for view: ToggleStyleLabel, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    return view.bodyBuild(context)
  }
}

extension ToggleStyleLabel: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}


// MARK: - Default Style

public typealias DefaultToggleStyle = SUIToggleStyle

extension StaticMember where Base : ToggleStyle {
  public static var `default` : DefaultToggleStyle.Member {
    return .init(base: .init())
  }
}

enum ToggleStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyToggleStyle {
    return AnyToggleStyle(DefaultToggleStyle())
  }
}

public extension EnvironmentValues {
  
  var toggleStyle: AnyToggleStyle {
    set { self[ToggleStyleEnvironmentKey.self] = newValue }
    get { self[ToggleStyleEnvironmentKey.self] }
  }
}

public extension View {
  
  func toggleStyle<S: ToggleStyle>(_ style: S.Member)
       -> EnvironmentView<AnyToggleStyle>
  {
    return environment(\.toggleStyle, AnyToggleStyle(style.base))
  }
}


// MARK: - Type Erased Style

public struct AnyToggleStyle: ToggleStyle {
  
  public typealias Label  = ToggleStyleLabel
  public typealias Member = StaticMember<Self>

  private var bodyBuild : ( Toggle<Label> ) -> AnyView
  
  init<S: ToggleStyle>(_ style: S) {
    self.bodyBuild = { configuration in
      return AnyView(style.body(configuration: configuration))
    }
  }

  public func body(configuration: Toggle<Label>) -> AnyView {
    return self.bodyBuild(configuration)
  }
}
