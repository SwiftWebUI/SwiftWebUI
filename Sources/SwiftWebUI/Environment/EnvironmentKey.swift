//
//  EnvironmentKey.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 10.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public protocol EnvironmentKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
}

enum SizeCategoryEnvironmentKey: EnvironmentKey {
  static var defaultValue: ContentSizeCategory { .medium }
}

enum IsEnabledEnvironmentKey: EnvironmentKey {
  static var defaultValue: Bool { true }
}

enum FontEnvironmentKey: EnvironmentKey {
  static var defaultValue: Font? { return nil }
}

enum ForegroundColorEnvironmentKey: EnvironmentKey {
  static var defaultValue: Color? { return nil }
}
enum BackgroundColorEnvironmentKey: EnvironmentKey {
  static var defaultValue: Color? { return nil }
}

enum ImageScaleEnvironmentKey: EnvironmentKey {
  static var defaultValue: Image.Scale { return .medium }
}

enum EditModeEnvironmentKey: EnvironmentKey {
  static var defaultValue: Binding<EditMode>? { return nil }
}

enum HorizontalSizeClassEnvironmentKey: EnvironmentKey {
  static var defaultValue: UserInterfaceSizeClass? { return .regular }
}
enum VerticalSizeClassEnvironmentKey: EnvironmentKey {
  static var defaultValue: UserInterfaceSizeClass? { return .regular }
}

import struct Foundation.Locale
import struct Foundation.TimeZone

enum LocaleEnvironmentKey: EnvironmentKey {
  static var defaultValue: Locale { return .current }
}
enum TimeZoneEnvironmentKey: EnvironmentKey {
  static var defaultValue: TimeZone { return .current }
}

enum EnvironmentObjectKey<O: ObservableObject>: EnvironmentKey {
  static var defaultValue: O? { return nil }
}

// MARK: - Value Access

extension EnvironmentValues {
  
  public var sizeCategory: ContentSizeCategory {
    set { self[SizeCategoryEnvironmentKey.self] = newValue }
    get { self[SizeCategoryEnvironmentKey.self] }
  }

  public var foregroundColor: Color? {
    set { self[ForegroundColorEnvironmentKey.self] = newValue }
    get { self[ForegroundColorEnvironmentKey.self] }
  }
  public var backgroundColor: Color? {
    set { self[BackgroundColorEnvironmentKey.self] = newValue }
    get { self[BackgroundColorEnvironmentKey.self] }
  }

  public var isEnabled: Bool  {
    set { self[IsEnabledEnvironmentKey.self] = newValue }
    get { self[IsEnabledEnvironmentKey.self] }
  }
  
  public var font: Font? {
    set { self[FontEnvironmentKey.self] = newValue}
    get { self[FontEnvironmentKey.self] }
  }

  public var imageScale: Image.Scale {
    set { self[ImageScaleEnvironmentKey.self] = newValue }
    get { self[ImageScaleEnvironmentKey.self] }
  }

  public var editMode: Binding<EditMode>? {
    set { self[EditModeEnvironmentKey.self] = newValue}
    get { self[EditModeEnvironmentKey.self] }
  }
  
  public var horizontalSizeClass: UserInterfaceSizeClass? {
    set { self[HorizontalSizeClassEnvironmentKey.self] = newValue }
    get { self[HorizontalSizeClassEnvironmentKey.self] }
  }
  public var verticalSizeClass: UserInterfaceSizeClass? {
    set { self[VerticalSizeClassEnvironmentKey.self] = newValue }
    get { self[VerticalSizeClassEnvironmentKey.self] }
  }
  
  public var locale: Locale {
    set { self[LocaleEnvironmentKey.self] = newValue}
    get { self[LocaleEnvironmentKey.self] }
  }
  public var timeZone: TimeZone {
    set { self[TimeZoneEnvironmentKey.self] = newValue}
    get { self[TimeZoneEnvironmentKey.self] }
  }
}

// MARK: - View Access

public extension View {
  
  typealias EnvironmentView<K> =
    ModifiedContent<Self, EnvironmentKeyWritingModifier<K>>

  func sizeCategory(_ category: ContentSizeCategory)
       -> EnvironmentView<ContentSizeCategory>
  {
    return environment(\.sizeCategory, category)
  }

  func foregroundColor(_ color: Color?) -> EnvironmentView<Color?> {
    return environment(\.foregroundColor, color)
  }
  func backgroundColor(_ color: Color?) -> EnvironmentView<Color?> {
    return environment(\.backgroundColor, color)
  }
  
  func isEnabled(_ enabled: Bool) -> EnvironmentView<Bool> {
    return environment(\.isEnabled, enabled)
  }
  func disabled(_ disabled: Bool) -> EnvironmentView<Bool> {
    return environment(\.isEnabled, !disabled)
  }

  func font(_ font: Font?) -> EnvironmentView<Font?> {
    return environment(\.font, font)
  }

  func imageScale(_ scale: Image.Scale) -> EnvironmentView<Image.Scale> {
    return environment(\.imageScale, scale)
  }
  
  func editMode(_ mode: Binding<EditMode>?)
       -> EnvironmentView<Binding<EditMode>?>
  {
    return environment(\.editMode, mode)
  }
  
  func horizontalSizeClass(_ sizeClass: UserInterfaceSizeClass?)
       -> EnvironmentView<UserInterfaceSizeClass?>
  {
    return environment(\.horizontalSizeClass, sizeClass)
  }
  func verticalSizeClass(_ sizeClass: UserInterfaceSizeClass?)
       -> EnvironmentView<UserInterfaceSizeClass?>
  {
    return environment(\.verticalSizeClass, sizeClass)
  }

  func locale(_ locale: Locale) -> EnvironmentView<Locale> {
    return environment(\.locale, locale)
  }
  func timeZone(_ timeZone: TimeZone) -> EnvironmentView<TimeZone> {
    return environment(\.timeZone, timeZone)
  }
}
