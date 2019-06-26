//
//  Image.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 16.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import struct Foundation.URL
import struct Foundation.Data
import class  Foundation.Bundle

#if canImport(CoreGraphics)
  import class CoreGraphics.CGImage
#endif

public struct Image: View, Equatable {
  public typealias Body = Never

  public init(_ name: String, bundle: Bundle? = nil, label: Text? = nil) {
    self.storage = .bundleImage(name, bundle: bundle, label: label)
  }
  public init(_ url: URL, label: Text? = nil) {
    self.storage = .url(url, label: label)
  }

  public enum TemplateRenderingMode: Hashable {
    case template, original
  }
  public enum Scale: Hashable {
    case small, medium, large
  }
  public enum Interpolation: Hashable {
    case none, low, medium, high
  }
  public enum ResizingMode: Hashable {
    case tile, stretch
  }

  enum ImageStorage : Equatable {
    case bundleImage(String, bundle: Bundle?, label: Text?)
    case url        (URL, label: Text?)
    case icon       (class: String)
    case data       (Data, mimeType: String)
    
    #if canImport(CoreGraphics)
      case cgImage(CGImage, scale: Length?, label: Text?)
    #endif
  }
  let storage : ImageStorage
}

extension HTMLTreeBuilder {

  func buildTree(for view: Image, in context: TreeStateContext) -> HTMLTreeNode
  {
    return HTMLImageNode(elementID : context.currentElementID,
                         storage   : view.storage,
                         scale     : context.environment.imageScale)
  }
  
}
extension Image: TreeBuildingView {
  func buildTree(in context: TreeStateContext) -> HTMLTreeNode {
    return context.currentBuilder.buildTree(for: self, in: context)
  }
}
