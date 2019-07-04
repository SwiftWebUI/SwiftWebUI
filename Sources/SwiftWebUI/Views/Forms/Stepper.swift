//
//  File.swift
//  
//
//  Created by Helge Heß on 27.06.19.
//

public struct Stepper<Label: View>: View {
  
  let onIncrement      : (()       -> Void)?
  let onDecrement      : (()       -> Void)?
  let onEditingChanged : (( Bool ) -> Void)?
  let label            : Label

  public init(onIncrement      : (()       -> Void)? = nil,
              onDecrement      : (()       -> Void)? = nil,
              onEditingChanged : (( Bool ) -> Void)? = nil,
              @ViewBuilder label: () -> Label)
  {
    self.onIncrement      = onIncrement
    self.onDecrement      = onDecrement
    self.onEditingChanged = onEditingChanged
    self.label            = label()
  }
  
  func increment() {
    onIncrement?()
    onEditingChanged?(false) // TBD
  }
  func decrement() {
    onDecrement?()
    onEditingChanged?(false) // TBD
  }

  public var body: some View {
    HStack {
      HTMLContainer(classes: [ "ui", "icon", "buttons", "small" ]) {
        // Enabling/Disabling +/- would be nice once bounds are hit
        Button(action: self.decrement) {
          HTMLContainer("i", classes: [ "minus", "icon" ], body: {EmptyView()})
        }
        Button(action: self.increment) {
          HTMLContainer("i", classes: [ "plus", "icon" ], body: {EmptyView()})
        }
      }
      label
    }
  }
}

public extension Stepper {

  init<V: Strideable>(value: Binding<V>,
                      in bounds: ClosedRange<V>, step: V.Stride = 1,
                      onEditingChanged: ((Bool) -> Void)? = nil,
                      @ViewBuilder label: () -> Label)
  {
    self.onIncrement = {
      let nextValue = value.wrappedValue.advanced(by: step)
      if bounds.contains(nextValue) {
        value.wrappedValue = nextValue
        onEditingChanged?(false) // TBD
      }
    }
    self.onDecrement = {
      let nextValue = value.wrappedValue.advanced(by: -step)
      if bounds.contains(nextValue) {
        value.wrappedValue = nextValue
        onEditingChanged?(false)
      }
    }
    self.onEditingChanged = nil
    self.label            = label()
  }

  
  init<V: Strideable>(value: Binding<V>, step: V.Stride = 1,
                      onEditingChanged: ((Bool) -> Void)? = nil,
                      @ViewBuilder label: () -> Label)
  {
    self.onIncrement = {
      value.wrappedValue = value.wrappedValue.advanced(by: step)
      onEditingChanged?(false) // TBD
    }
    self.onDecrement = {
      value.wrappedValue = value.wrappedValue.advanced(by: -step)
      onEditingChanged?(false)
    }
    self.onEditingChanged = nil
    self.label            = label()
  }
}
