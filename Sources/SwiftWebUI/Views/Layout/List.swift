//
//  List.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 23.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//
public struct List<Selection: SelectionManager, Content: View>: View {

  public typealias Body = Never

  let selection : Binding<Selection>?
  let content   : Content
  
  public init(selection: Binding<Selection>?,
              @ViewBuilder content: () -> Content)
  {
    self.selection = selection
    self.content   = content()
  }
}

public extension List where Selection == Never {
  
  init(@ViewBuilder content: () -> Content) {
    self.selection = nil
    self.content   = content()
  }
  
  init<Data, RowContent>(_ data: Data,
                         @ViewBuilder rowContent:
                         @escaping (Data.Element.IdentifiedValue) -> RowContent)
    where Content == ForEach<Data, HStack<RowContent>>,
          Data         : RandomAccessCollection,
          Data.Element : Identifiable,
          RowContent   : View
  {
    self.selection = nil
    self.content = ForEach(data) { value in
      HStack(alignment: .center, spacing: nil) {
        rowContent(value)
      }
    }
  }
  
  init<Data, RowContent>(
    _ data: Data,
    action: @escaping (Data.Element.IdentifiedValue) -> Void,
    @ViewBuilder rowContent:
    @escaping (Data.Element.IdentifiedValue) -> RowContent
  )
    where Content == ForEach<Data, AnyView>,
          Data         : RandomAccessCollection,
          Data.Element : Identifiable,
          RowContent   : View
  {
    // TODO: action
    self.selection = nil
    
    self.content = ForEach(data) { value in
      AnyView(
        HStack(alignment: .center, spacing: nil) {
          rowContent(value)
        }
        .tapAction { action(value) }
      )
    }
  }
}

public extension List {
  
  init<Data, RowContent>(_ data     : Data,
                         selection  : Binding<Selection>?,
                         @ViewBuilder rowContent:
                         @escaping (Data.Element.IdentifiedValue) -> RowContent)
    where Content == ForEach<Data, AnyView>,
          Data         : RandomAccessCollection,
          Data.Element : Identifiable,
          RowContent   : View
  {
    self.selection = selection
    self.content = ForEach(data) { (value : Data.Element) in
      AnyView(
        HStack(alignment: .center, spacing: nil) {
          rowContent(value.identifiedValue)
        }
        .tag(value.id)
      )
    }
  }
  
  init<Data, RowContent>(
    _ data     : Data,
    selection  : Binding<Selection>?,
    action     : @escaping (Data.Element.IdentifiedValue) -> Void,
    @ViewBuilder rowContent:
    @escaping (Data.Element.IdentifiedValue) -> RowContent
  ) where Content == ForEach<Data, AnyView>,
          Data         : RandomAccessCollection,
          Data.Element : Identifiable,
          Selection.SelectionValue == Data.Element.ID,
          RowContent   : View
  {
    self.selection = selection
    self.content = ForEach(data) { (value : Data.Element) in
      AnyView(
        HStack(alignment: .center, spacing: nil) {
          rowContent(value.identifiedValue)
        }
        .tapAction { action(value.identifiedValue) }
          // this conflicts w/ the selection
        .tag(value.id) // doesn't work in front of tapAction?!
      )
    }
  }
}

extension List: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
