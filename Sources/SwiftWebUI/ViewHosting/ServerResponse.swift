//
//  ServerResponse.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 19.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import NIO
import NIOHTTP1

open class ServerResponse {
  
  private let request        : HTTPRequestHead
  public  var status         = HTTPResponseStatus.ok
  public  var headers        = HTTPHeaders()
  public  let channel        : Channel
  private var didWriteHeader = false
  private var didEnd         = false
  
  public init(request: HTTPRequestHead, channel: Channel) {
    self.request = request
    self.channel = channel
  }

  /// An Express like `send()` function.
  open func send(_ s: String) {
    flushHeader()
    guard !didEnd else { return }
    
    let utf8   = s.utf8
    var buffer = channel.allocator.buffer(capacity: utf8.count)
    buffer.writeBytes(utf8)
    
    let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
    
    _ = channel.writeAndFlush(part)
               .recover(handleError)
               .map { self.end() }
  }
  
  /// Check whether we already wrote the response header.
  /// If not, do so.
  func flushHeader() {
    guard !didWriteHeader else { return } // done already
    didWriteHeader = true
    
    var head = HTTPResponseHead(version: .init(major:1, minor:1),
                                status: status, headers: headers)
    head.headers.add(name: "Connection", value: "close") // Yikes ;-)

    let part = HTTPServerResponsePart.head(head)
    _ = channel.writeAndFlush(part).recover(handleError)
  }
  
  func handleError(_ error: Error) {
    print("ERROR:", error)
    end()
  }
  
  func end() {
    guard !didEnd else { return }
    didEnd = true
    _ = channel.writeAndFlush(HTTPServerResponsePart.end(nil))
               .map { self.channel.close() }
  }
}

public extension ServerResponse {
  
  /// A more convenient header accessor. Not correct for
  /// any header.
  subscript(name: String) -> String? {
    set {
      assert(!didWriteHeader, "header is out!")
      if let v = newValue {
        headers.replaceOrAdd(name: name, value: v)
      }
      else {
        headers.remove(name: name)
      }
    }
    get {
      return headers[name].joined(separator: ", ")
    }
  }
}

public extension ServerResponse {

  /// An Express like `send()` function which arbitrary "Data" objects
  /// (i.e. collections of type UInt8)
  func send<S: Collection>(_ bytes: S) where S.Element == UInt8 {
    flushHeader()
    guard !didEnd else { return }

    var buffer = channel.allocator.buffer(capacity: bytes.count)
    buffer.writeBytes(bytes)
    
    let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
    
    _ = channel.writeAndFlush(part)
               .recover(handleError)
               .map { self.end() }
  }

}

import Foundation


// MARK: - JSON

public extension ServerResponse {
  
  /// Send a Codable object as JSON to the client.
  func json<T: Encodable>(_ model: T) {
    // create a Data struct from the Codable object
    let data : Data
    do {
      data = try JSONEncoder().encode(model)
    }
    catch {
      return handleError(error)
    }
    
    // setup JSON headers
    self["Content-Type"]   = "application/json"
    self["Content-Length"] = "\(data.count)"
    
    // send the headers and the data
    flushHeader()
    guard !didEnd else { return }

    var buffer = channel.allocator.buffer(capacity: data.count)
    buffer.writeBytes(data)
    let part = HTTPServerResponsePart.body(.byteBuffer(buffer))

    _ = channel.writeAndFlush(part)
               .recover(handleError)
               .map { self.end() }
  }
}


// MARK: - Mustache

public extension ServerResponse {
  
  private func path(to resource: String, ofType type: String,
                    in pathContext: String) -> String?
  {
    #if os(iOS) && !arch(x86_64) // iOS support, FIXME: blocking ...
      return Bundle.main.path(forResource: resource, ofType: type)
    #else
      var url = URL(fileURLWithPath: pathContext)
      url.deleteLastPathComponent()
      url.appendPathComponent("templates", isDirectory: true)
      url.appendPathComponent(resource)
      url.appendPathExtension(type)
      return url.path
    #endif
  }
}
