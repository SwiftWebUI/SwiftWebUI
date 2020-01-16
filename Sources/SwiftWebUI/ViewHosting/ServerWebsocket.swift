//
//  ServerWebsocket.swift
//  SwiftWebUI
//
//  Created by Szymon Lorenz on 16/1/20.
//
//  Inspired from:
//  https://github.com/apple/swift-nio/blob/master/Sources/NIOWebSocketServer/main.swift

import struct  Foundation.Data
import class   Foundation.JSONDecoder
import class   Foundation.JSONEncoder
import Dispatch
import NIO
import NIOWebSocket

typealias SwiftUIEvent = NIOEndpoint.SwiftUIEvent

extension ChannelHandlerContext: Hashable {
    public func hash(into hasher: inout Hasher) {
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        hasher.combine(String(describing: opaque))
    }
    
    public static func == (lhs: ChannelHandlerContext, rhs: ChannelHandlerContext) -> Bool {
        lhs === rhs
    }
}

internal class WebSocketConnection {
    let sessionId: String
    var awaitingClose: Bool = false
    
    init(sessionId: String) {
        self.sessionId = sessionId
    }
}

final class WebSocket: ChannelInboundHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame

    private var onEventCallback: ((SwiftUIEvent, WebSocket, ChannelHandlerContext) -> Void)? = nil
    private var onConnectCallback: ((String, WebSocket, ChannelHandlerContext) -> Void)? = nil //Would be good to know sessionID without retriving it from the client. Any idea how we can connect initialPage GET with websocket connection?
    private var onDisconnectCallback: ((_ sessionId: String) -> Void)? = nil
    private var dispatch = DispatchSemaphore(value: 1)
    private var connections: [ChannelHandlerContext: WebSocketConnection] = [:]
    
    deinit {
        onEventCallback = nil
        onConnectCallback = nil
        onDisconnectCallback = nil
        connections.removeAll(keepingCapacity: false)
    }
    
    public func onEvent(_ callback: @escaping (SwiftUIEvent, WebSocket, ChannelHandlerContext) -> Void) -> Self {
        onEventCallback = callback
        return self
    }
    
    public func onClientConnect(_ callback: @escaping (String, WebSocket, ChannelHandlerContext) -> Void) -> Self {
        onConnectCallback = callback
        return self
    }
    
    public func onClientDisconnect(_ callback: @escaping (String) -> Void) -> Self {
        onDisconnectCallback = callback
        return self
    }
    
    public func handlerAdded(context: ChannelHandlerContext) {
        self.sendTime(context: context)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)

        switch frame.opcode {
        case .connectionClose:
            self.receivedClose(context: context, frame: frame)
        case .ping:
            self.pong(context: context, frame: frame)
        case .text:
            var data = frame.unmaskedData
            let text = data.readString(length: data.readableBytes) ?? ""
            print("Websocket text:", text)
            do {
                if let data = text.data(using: .utf8) {
                    let event = try JSONDecoder().decode(SwiftUIEvent.self, from: data)
                    if let connection = self.connections[context], connection.sessionId != event.wosid {
                        fatalError("Websocket session ids do not match!")
                    } else {
                        _ = dispatch.wait(timeout: DispatchTime.distantFuture)
                        self.connections[context] = WebSocketConnection(sessionId: event.wosid)
                        dispatch.signal()
                    }
                    self.onEventCallback?(event, self, context)
                } else {
                    if let json = String(data: try JSONEncoder().encode(CodableHate(error: "Unable to decode frame.")), encoding: .utf8) {
                        send(context: context, string: json)
                    }
                }
            } catch {
                print("Websocket error:", error)
                if let data = try? JSONEncoder().encode(CodableHate(error: error.localizedDescription)), let json = String(data: data, encoding: .utf8) {
                    send(context: context, string: json)
                }
            }
        case .binary, .continuation, .pong:
            // We ignore these frames.
            break
        default:
            // Unknown frames are errors.
            self.closeOnError(context: context)
        }
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    public func send<T: Encodable>(context: ChannelHandlerContext, object: T) throws {
        send(context: context, data:  try JSONEncoder().encode(object))
    }
    
    public func send(context: ChannelHandlerContext, data: Data) {
        print("Websocket send data")
        context.eventLoop.execute {
            guard context.channel.isActive else { return }

            // We can't send if we sent a close message.
            guard self.connections[context]?.awaitingClose == false else { return }

            // We can't really check for error here, but it's also not the purpose of the
            // example so let's not worry about it.
            var buffer = context.channel.allocator.buffer(capacity: data.count)
            buffer.writeBytes(data)

            let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
            context.writeAndFlush(self.wrapOutboundOut(frame)).whenFailure { (_: Error) in
                context.close(promise: nil)
            }
        }
    }
    
    public func send(context: ChannelHandlerContext, string: String) {
        print("Websocket send text")
        context.eventLoop.execute {
            guard context.channel.isActive else { return }

            // We can't send if we sent a close message.
            guard self.connections[context]?.awaitingClose == false else { return }

            // We can't really check for error here, but it's also not the purpose of the
            // example so let's not worry about it.
            var buffer = context.channel.allocator.buffer(capacity: Array(string.utf8).count)
            buffer.writeString(string)

            let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
            context.writeAndFlush(self.wrapOutboundOut(frame)).whenFailure { (_: Error) in
                context.close(promise: nil)
            }
        }
    }
    
    private func sendTime(context: ChannelHandlerContext) {
        send(context: context, string: "\(NIODeadline.now().uptimeNanoseconds)")
    }

    private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
        // Handle a received close frame. In websockets, we're just going to send the close
        // frame and then close, unless we already sent our own close frame.
        if self.connections[context]?.awaitingClose == true {
            // Cool, we started the close and were waiting for the user. We're done.
            context.close(promise: nil)
        } else {
            // This is an unsolicited close. We're going to send a response frame and
            // then, when we've sent it, close up shop. We should send back the close code the remote
            // peer sent us, unless they didn't send one at all.
            var data = frame.unmaskedData
            let closeDataCode = data.readSlice(length: 2) ?? context.channel.allocator.buffer(capacity: 0)
            let closeFrame = WebSocketFrame(fin: true, opcode: .connectionClose, data: closeDataCode)
            _ = context.write(self.wrapOutboundOut(closeFrame)).map { () in
                context.close(promise: nil)
                if let sessionId = self.connections[context]?.sessionId {
                    self.onDisconnectCallback?(sessionId)
                }
            }
        }
    }

    private func pong(context: ChannelHandlerContext, frame: WebSocketFrame) {
        var frameData = frame.data
        let maskingKey = frame.maskKey

        if let maskingKey = maskingKey {
            frameData.webSocketUnmask(maskingKey)
        }

        let responseFrame = WebSocketFrame(fin: true, opcode: .pong, data: frameData)
        context.write(self.wrapOutboundOut(responseFrame), promise: nil)
    }

    private func closeOnError(context: ChannelHandlerContext) {
        // We have hit an error, we want to close. We do that by sending a close frame and then
        // shutting down the write side of the connection.
        var data = context.channel.allocator.buffer(capacity: 2)
        data.write(webSocketErrorCode: .protocolError)
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        context.write(self.wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
            context.close(mode: .output, promise: nil)
            if let sessionId = self.connections[context]?.sessionId {
                self.onDisconnectCallback?(sessionId)
            }
        }
        self.connections[context]?.awaitingClose = true
    }
}
