//
//  NIOEndpoint.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 19.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import class  Foundation.Bundle
import struct Foundation.Data
import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem
import NIO
import NIOHTTP1

// The HTTP endpoint hosting the Views. This is really just a quick hack
// based on some SwiftObjects and MicroExpress code.
//
// Good enough to serve the demo, but a proper implementation would have to
// add at least some security safeguards (e.g. cookie handling, maybe JWT,
// don't know).
// => Improvements are welcome.
//
// Also this currently only does HTTP. We could very easily add support for
// WebSockets ala `miniircd` and achieve two way communication by that.
//
// P.S. I originally had this as a SwiftObjects
//      `WORequestHandler` / `WOViewHostingComponent` setup.
//      Ping me if interested.

public final class NIOEndpoint {
  
  public static let shared = NIOEndpoint()
  
  public init() {}
  
  
  // MARK: - RootView
  
  var view : AnyView?
  
  public func use<T: View>(_ view: T) {
    // we could support different views per URL (kinda like Routing)
    assert(self.view == nil, "currently only supporting a single view :-)")
    self.view = AnyView(view)
  }

  
  // MARK: - Sessions
  
  // Yeah, no expiry, no nothing :-)
  // If we did WebSockets, we could attach it to the session (but allow for
  // a short reconnect timeframe).
  private var sessions = [ String : NIOHostingSession ]()
  
  
  // MARK: - Expose Binary Resource URLs
  
  // TODO: Support registry of bundle resources. Do not make all resources
  //       available!
  public func expose(_ content: Data, as name: String) {
    memoryResources[name] = .init(name, content)
  }

  public func url(forResource name: String, in bundle: Bundle) -> String? {
    let internalName = bundle.bundleKey + "\t" + name
    if let extName = publicPathes.internalKeyToPublicName[internalName] {
      guard publicPathes.publicNameToResource[extName] != nil else {
        return nil // did not find resource
      }
      return "/www/" + extName
    }
    
    guard let url = bundle.url(forResource: name, withExtension: nil) else {
      print("WARN: did not find resource:", name)
      publicPathes.internalKeyToPublicName[internalName] = "404"
      return nil
    }
    
    // Note really necessary, we essentially make it fully public. Though we
    // might wanna tie the map to the session?
    let extName : String = {
      let sid = NIOHostingSession.createSessionID(), pe = url.pathExtension
      if pe.isEmpty { return sid }
      return sid + "." + pe
    }()

    publicPathes.internalKeyToPublicName[internalName] = extName
    publicPathes.publicNameToResource[extName] = url
    return "/www/" + extName
  }

  
  // MARK: - Handling Events
  
  enum SwiftUIError : String, Swift.Error {
    case missingEventData = "missing-event-data"
    case notImplemented   = "not-implemented"
    case contextNotFound  = "context-not-found"
    case otherError       = "unknown-error"
    case missingView      = "missing-view"
    
    var status : HTTPResponseStatus { return .internalServerError }
  }
  
  struct SwiftUIEvent {
    enum EventType: String {
      case click
      case commit
      case change
    }
    let wosid : String
    let wocid : String // we might want that later
    let event : EventType
    let webID : [ String ]
    let value : String?
    
    init?(queryParameters: [ String: String ]) {
      guard let wosid = queryParameters["wosid"], !wosid.isEmpty,
            let wocid = queryParameters["wocid"], !wocid.isEmpty,
            let event = queryParameters["event"].flatMap(EventType.init),
            let eid   = queryParameters["eid"], !eid.isEmpty else {
        return nil
      }
      self.wosid = wosid
      self.wocid = wocid
      self.event = event
      self.webID = eid.components(separatedBy: ".")
      self.value = queryParameters["value"]
    }
  }
  
  private func handle(event: SwiftUIEvent, response: ServerResponse) throws {
    guard let session = sessions[event.wosid] else {
      return response.fail(.contextNotFound)
    }
    try session.handle(event: event, response: response)
  }
  
  
  // MARK: - Page and Session Setup
  
  private func sendInitialPage(to response: ServerResponse) throws {
    guard let view = view else {
      throw SwiftUIError.missingView
    }
    
    let sessionID = NIOHostingSession.createSessionID()
    let session   = NIOHostingSession(sessionID: sessionID, view: view)
    
    try session.sendInitialPage(to: response)
    sessions[sessionID] = session // only save when this worked
  }
  
  
  // MARK: - Primary Request Entry Points

  private func sendResource(_ content: Data, uri: String,
                            to response: ServerResponse)
  {
    func mimeType(for path: String) -> String? {
      return WOExtensionToMimeType[URL(fileURLWithPath: path).pathExtension]
    }
    
    let type = mimeType(for: uri) ?? "application/octet-stream"
    response.headers.replaceOrAdd(name: "Content-Type", value: type)
    if content.count > 10 { // GZip: 1F 8B - hack :-)
      if content[0] == 0x1F, content[1] == 0x8B {
        response.headers.replaceOrAdd(name: "Content-Encoding", value : "gzip")
      }
    }
    return response.send(content)
  }

  private func handle(request: HTTPRequestHead, response: ServerResponse) {
    // Yup, this is pretty hardcoded, but we don't do that much here.
    
    #if DEBUG && true
      print("\(request.method) \(request.uri)")
    #endif
    
    if request.uri.hasPrefix("/www/") {
      let memKey = String(request.uri.dropFirst(5))
      
      if let memResource = memoryResources[memKey] {
        return sendResource(memResource.content, uri: request.uri, to: response)
      }
      
      if let url = publicPathes.publicNameToResource[memKey] {
        // FIXME: Use NIO + sendfile to stream the URL
        guard let data = try? Data(contentsOf: url) else {
          return response.fail(.otherError)
        }
        return sendResource(data, uri: request.uri, to: response)
      }
      
      response.status = .notFound
      return response.send("Not Found: \(request.uri)")
    }

    do {
      if request.method == .POST {
        // FIXME: decode this from a JSON body ...
        if let event = SwiftUIEvent(queryParameters: request.queryParameters) {
          return try handle(event: event, response: response)
        }
        else {
          return response.fail(.missingEventData)
        }
      }
      else if request.method == .GET {
        return try sendInitialPage(to: response)
      }
      
      response.status = .internalServerError
      response.send("Unexpected HTTP Request, giving up!")
    }
    catch let error as SwiftUIError {
      print("ERROR:", error)
      return response.fail(.notImplemented)
    }
    catch {
      print("ERROR:", error)
      return response.fail(.otherError)
    }
  }
  

  // MARK: - NIO Boilerplate
  
  // Note: Not everything is multi threaded yet. Can be done, but some extra
  //       work.
  private let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  private var serverChannel : Channel?
  
  public func wait() {
    assert(serverChannel != nil, "NIO channel not setup?")
    try? serverChannel?.closeFuture.wait()
  }
  
  public func listen(_ port    : Int    = 1337,
                     _ host    : String = "127.0.0.1",
                     _ backlog : Int    = 256)
  {
    assert(serverChannel == nil, "NIO already setup")
    let bootstrap = self.createServerBootstrap(backlog)
    
    do {
      serverChannel = try bootstrap.bind(host: host, port: port).wait()
      print("Server running on:", serverChannel!.localAddress!)
    }
    catch {
      fatalError("failed to start server: \(error)")
    }
  }
  private func createServerBootstrap(_ backlog : Int) -> ServerBootstrap {
    let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET),
                                             SO_REUSEADDR)
    let bootstrap = ServerBootstrap(group: loopGroup)
      .serverChannelOption(ChannelOptions.backlog, value: Int32(backlog))
      .serverChannelOption(reuseAddrOpt, value: 1)
      
      .childChannelInitializer { channel in
          return channel.pipeline.configureHTTPServerPipeline().flatMap {
            _ in
            channel.pipeline.addHandler(HTTPHandler(endpoint: self))
          }
      }
      
      .childChannelOption(ChannelOptions.socket(
        IPPROTO_TCP, TCP_NODELAY), value: 1)
      .childChannelOption(reuseAddrOpt, value: 1)
      .childChannelOption(ChannelOptions.maxMessagesPerRead,
                          value: 1)
    return bootstrap
  }

  final class HTTPHandler : ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    
    let endpoint : NIOEndpoint
    
    init(endpoint: NIOEndpoint) {
      self.endpoint = endpoint
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
      let reqPart = self.unwrapInboundIn(data)
      
      switch reqPart {
        case .head(let header):
          let res = ServerResponse(channel: context.channel)
          endpoint.handle(request: header, response: res)

        // ignore incoming content to keep it micro :-)
        case .body, .end: break
      }
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
      print("socket error, closing connection:", error)
      context.close(promise: nil)
    }
  }

  private struct InMemoryResource {
    let name        : String
    let contentType : String?
    let content     : Data
    let isGZipped   : Bool
    
    public init(_ name: String, _ content: Data,
                contentType: String? = nil,
                zipped: Bool = true)
    {
      self.name        = name
      self.contentType = contentType
      self.content     = content
      self.isGZipped   = zipped
    }
  }

  private var memoryResources = [ String : InMemoryResource ]()
  
  private final class PublicResourceMap {
    var internalKeyToPublicName = [ String : String ]()
    var publicNameToResource    = [ String : URL    ]()
  }
  private let publicPathes = PublicResourceMap()
}

extension HTTPRequestHead {

  var queryParameters : [ String : String ] {
    guard let qi = URLComponents(string: uri)?.queryItems else {
      return [:]
    }
    return Dictionary<String, [URLQueryItem]>(grouping: qi, by: { $0.name })
           .mapValues { $0.compactMap({ $0.value }).joined(separator: ",") }
  }

}

extension ServerResponse {
  
  func fail(_ error: NIOEndpoint.SwiftUIError) {
    status = error.status
    struct CodableHate: Encodable {
      let ok    = false
      let error : String
    }
    self.json(CodableHate(error: error.rawValue))
  }

}

fileprivate extension Bundle {
  var bundleKey: String {
    if self === Bundle.main { return "MAIN" }
    return bundlePath
  }
}

let WOExtensionToMimeType : [ String : String ] = [
  "css"  : "text/css",
  "txt"  : "text/plain",
  "js"   : "text/javascript",
  "gif"  : "image/gif",
  "png"  : "image/png",
  "jpeg" : "image/jpeg",
  "jpg"  : "image/jpeg",
  "html" : "text/html",
  "xml"  : "text/xml",
  "ico"  : "image/x-icon"
]
