//
//  Picker.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 26.06.19.
//  Copyright © 2019-2024 Helge Heß. All rights reserved.
//

public struct Picker<Label: View, SelectionValue: Hashable, Content: View>: View
{
  
  let selection : Binding<SelectionValue>
  let label     : Label
  let content   : Content
  
  public init(selection: Binding<SelectionValue>, label: Label,
              @ViewBuilder content: () -> Content)
  {
    self.selection = selection
    self.label     = label
    self.content   = content()
  }
}
extension HTMLTreeBuilder {
  
  func buildTree<Label: View, SelectionValue: Hashable, Content: View>(
         for view: Picker<Label, SelectionValue, Content>,
         in context: TreeStateContext) -> HTMLTreeNode
  {
    let config = PickerStyleConfiguration(label: PickerStyleLabel(view.label),
                                          selection: view.selection,
                                          body: AnyView(view.content))
    let style        = context.environment.pickerStyle
    let concreteView = style.body(configuration: config)
    return context.currentBuilder.buildTree(for: concreteView, in: context)
  }
}
extension Picker: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}


// MARK: - Style

public protocol PickerStyle {
  
  // later ;-): associatedtype Body : View
  
  typealias Member = StaticMember<Self>
  typealias Configuration<S: Hashable> = PickerStyleConfiguration<S>
  
  func body<S: Hashable>(configuration: Configuration<S>) -> AnyView
}

public struct PickerStyleConfiguration<SelectionValue>
                where SelectionValue : Hashable
{
  public var label     : PickerStyleLabel
  public var selection : Binding<SelectionValue>
  public var body      : AnyView
}


// MARK: - Type Erased Label

public struct PickerStyleLabel : View {
  public typealias Body = Never
  
  fileprivate var bodyBuild : ( TreeStateContext ) -> HTMLTreeNode
  
  init<V: View>(_ view: V) {
    self.bodyBuild = { context in
      return context.currentBuilder.buildTree(for: view, in: context)
    }
  }
}

extension HTMLTreeBuilder {
  func buildTree(for view: PickerStyleLabel, in context: TreeStateContext)
       -> HTMLTreeNode
  {
    return view.bodyBuild(context)
  }
}

extension PickerStyleLabel: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    context.currentBuilder.buildTree(for: self, in: context)
  }
}


// MARK: - Default Style

public typealias DefaultPickerStyle = PopUpButtonPickerStyle

public extension StaticMember where Base : PickerStyle {
  
  static var `default` : DefaultPickerStyle.Member {
    return .init(base: .init())
  }
}


// MARK: - Environment

enum PickerStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyPickerStyle {
    return AnyPickerStyleBox(DefaultPickerStyle())
  }
}

public extension EnvironmentValues {
  
  var pickerStyle: AnyPickerStyle {
    set { self[PickerStyleEnvironmentKey.self] = newValue }
    get { self[PickerStyleEnvironmentKey.self] }
  }
}

extension View {
  
  public func pickerStyle<S: PickerStyle>(_ style: S.Member)
              -> EnvironmentView<AnyPickerStyle>
  {
    return environment(\.pickerStyle, AnyPickerStyleBox(style.base))
  }
}

// MARK: - Type Erased Style

public class AnyPickerStyle: PickerStyle {
  public typealias Label  = PickerStyleLabel
  public typealias Member = StaticMember<AnyPickerStyle>

  public func body<S: Hashable>(configuration: Configuration<S>) -> AnyView {
    fatalError("subclass responsibility: \(#function)")
  }
}
final class AnyPickerStyleBox<S: PickerStyle>: AnyPickerStyle {
  
  let style : S
  
  init(_ style: S) { self.style = style }

  override func body<CS: Hashable>(configuration: Configuration<CS>) -> AnyView {
    return AnyView(style.body(configuration: configuration))
  }
}
