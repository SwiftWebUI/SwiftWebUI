//
//  NavigationView.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public struct NavigationView<Root: View>: View {
  
  #if false // using @State within the same module crashes the compiler (beta2)
    @State var navigationContext = NavigationContextHolder()
  #else
    private var navigationContext : State<NavigationContext>
  #endif
  
  private let root      : Root
  private let emptyView : AnyView
  
  public init<EV: View>(emptyView: EV, @ViewBuilder root: () -> Root) {
    self.root = root()
    self.emptyView = AnyView(emptyView)
    navigationContext = .init(initialValue: NavigationContext(emptyView))
  }
  public init(@ViewBuilder root: () -> Root) {
    self.init(emptyView: VStack {
      Spacer()
      Text("No Selection")
      Spacer()
    }, root: root)
  }

  public var body: some View {
    HTMLContainer(classes: [ "swiftui-navigation" ]) {
      NavigationSidebar(root: root)
      NavigationContent()
    }
    .environmentObject(navigationContext.value)
  }
}

public extension View {
  
  func navigationBarTitle(_ item: Text,
                          displayMode : NavigationBarItem.TitleDisplayMode
                                      = .automatic)
         -> Self.Modified<TraitWritingModifier<NavigationBarItem>>
  {
    // TBD: we probably want a different trait just for the title
    let v = NavigationBarItem(view: AnyView(item), displayMode: displayMode)
    return modifier(TraitWritingModifier(content: v))
  }
}

extension NavigationBarItem: Trait {}
