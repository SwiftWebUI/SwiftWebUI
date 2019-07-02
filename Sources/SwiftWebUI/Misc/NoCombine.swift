//
//  NoCombine.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 22.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

#if !canImport(Combine)

// TODO: This needs more work. Just the basics to get synchronous event emitters
//       working w/o Combine.

public protocol Cancellable {
  func cancel()
}

public class AnyCancellable {
  
  private let wrappedCancel : Cancellable
  
  init<C: Cancellable>(_ cancellable: C) { wrappedCancel = cancellable }
  deinit { wrappedCancel.cancel() }
}

public protocol Subscription : Cancellable  {
  func request(_ demand: Subscribers.Demand)
}

public protocol Subscriber {
  associatedtype Input
  associatedtype Failure : Error
  
  func receive(subscription: Subscription)
  func receive(_ input: Input) -> Subscribers.Demand
  func receive(completion: Subscribers.Completion<Failure>)
}

public enum Subscribers {
  public enum Demand: Equatable, Comparable {
    case unlimited
    public static func < (lhs: Self, rhs: Self) -> Bool {
      return true
    }
  }
  public enum Completion<Failure: Error> {
    case finished
    case failure(Failure)
  }
}

public protocol Publisher {
  associatedtype Output
  associatedtype Failure : Swift.Error
  
  func receive<S: Subscriber>(subscriber: S)
         where Self.Failure == S.Failure, Self.Output == S.Input
}

public protocol Subject : AnyObject, Publisher {
  func send(_ value: Output)
  func send(completion: Subscribers.Completion<Failure>)
}

final public class PassthroughSubject<Output, Failure: Error>: Subject {
  
  // TODO: gimme some simple implementation
  
  public init() {}
  
  public func receive<S: Subscriber>(subscriber: S)
                where Output == S.Input, Failure == S.Failure
  {
    print("ERROR: not handling subscriber:", subscriber)
  }
  
  final public func send(_ input: Output) {
    print("ERROR: not publishing:", input)
  }
  final public func send(completion: Subscribers.Completion<Failure>) {
    print("ERROR: not sending completion:", completion)
  }
}

public extension Subscribers {

  final class Sink<Upstream: Publisher>: Subscriber, Cancellable {

     public typealias Input   = Upstream.Output
     public typealias Failure = Upstream.Failure
     
     public let receiveCompletion : ( Subscribers.Completion<Upstream.Failure> ) -> Void
     public let receiveValue      : ( Upstream.Output ) -> Void
     
     func receive(subscription: Subscription) {
     }
     func receive(_ input: Input) -> Subscribers.Demand {
       receiveValue(input)
     }
     func receive(completion: Subscribers.Completion<Failure>) {
       receiveCompletion(completion)
     }
   }
}

public extension Publisher {
  func sink(receiveCompletion : (( Subscribers.Completion<Self.Failure> ) -> Void)? = nil,
            receiveValue      : @escaping ( Self.Output ) -> Void)
       -> Subscribers.Sink<Self>
  {
    print("ERROR: not sending completion:", completion)
    return Sink(receiveCompletion, receiveCompletion ?? { _ in },
                receiveValue: receiveValue)
  }
}

#endif // !canImport(Combine)
