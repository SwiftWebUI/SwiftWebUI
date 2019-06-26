//
//  HTMLImageNode.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import struct Foundation.Data
import class  Foundation.Bundle

struct HTMLImageNode: HTMLLeafNode {
  
  typealias ImageStorage = Image.ImageStorage
  
  let elementID : ElementID
  let storage   : ImageStorage
  let scale     : Image.Scale
  
  private var url : String? {
    switch storage {
      case .url(let url, _):
        return url.absoluteString

      case .icon:
        return nil
      
      case .bundleImage(let name, let bundle, _):
        let bundle = bundle ?? Bundle.main
        #if true // NIOEndpoint
          return NIOEndpoint.shared.url(forResource: name, in: bundle)
        #else
          return bundle.dataURL(forResource: name, withExtension: nil)
        #endif

      case .data(let data, let mimeType):
        // TBD: We could also hook it up under a NIOEndpoint URL. Maybe
        //      depending on it's size? (that would actually be pretty good
        //      given that the images can be quite large).
        guard !data.isEmpty else { return nil }
        return data.generateDataURL(using: mimeType)
      
      #if canImport(CoreGraphics)
        case .cgImage(let image, _, _):
          // TBD: we could also hook it up under a NIOEndpoint URL
          guard let data = image.generateData(type: "public.png") else {
            return nil
          }
          return data.generateDataURL(using: "image/png")
      #endif
    }
  }
  private var classes: String? {
    switch storage {
      case .icon(let classes):
        return classes + " " + scale.cssStringValue
      
      case .url, .bundleImage, .data: return nil
      #if canImport(CoreGraphics)
        case .cgImage: return nil
      #endif
    }
  }
  
  func generateHTML(into html: inout String) {
    // TODO: `alt` / `title` (label Text, not sure how, probably special
    //                        support for extracting plain text)
    if let url = url {
      html += "<img class=\"swiftui-image\""
      html.appendAttribute("id",  elementID.webID)
      if let classes = classes { html.appendAttribute("class", classes) }
      html.appendAttribute("src", url)
      html += " />"
    }
    else if let classes = classes {
      // https://semantic-ui.com/elements/icon.html
      html += "<i class=\"swiftui-image icon \(classes)\""
      html.appendAttribute("id",  elementID.webID)
      html += "></i>"
    }
    else {
      // Hmmmmm. We might need to replace the thing
      html += "<img class=\"swiftui-image\""
      html.appendAttribute("id",  elementID.webID)
      html += " />"
    }
  }
  
  func generateChanges(from   oldNode : HTMLTreeNode,
                       into changeset : inout [ HTMLChange ],
                       in     context : TreeStateContext)
  {
    guard let oldNode = sameType(oldNode, &changeset) else { return }
    
    guard oldNode.storage != storage else { return }

    changeset.append(
      .setAttribute(webID: elementID.webID,
                    attribute: "src", value: url ?? "")
    )
  }

  // MARK: - Debugging

  public func dump(nesting: Int) {
    let indent = String(repeating: "  ", count: nesting)
    print("\(indent)<Image: \(storage)>")
  }
}

extension Image.Scale : CSSStyleValue {
  
  public var cssStringValue: String {
    switch self {
      case .small:  return "small"
      case .medium: return ""
      case .large:  return "large"
    }
  }
}

extension Bundle {
  
  func dataURL(forResource name: String, withExtension e: String?) -> String? {
    guard let localURL = self.url(forResource: name, withExtension: e) else {
      return nil
    }
    guard let data = try? Data(contentsOf: localURL) else {
      print("could not load resource:", name, "in:", self)
      return nil
    }
    // FIXME: Use UTI when available
    let mimeType = WOExtensionToMimeType[localURL.pathExtension.lowercased()]
    return data.generateDataURL(using: mimeType ?? "application/octet-stream")
  }

}

extension Data {
  
  func generateDataURL(using mimeType: String) -> String {
    return "data:\(mimeType);base64," + self.base64EncodedString()
  }
  
}
