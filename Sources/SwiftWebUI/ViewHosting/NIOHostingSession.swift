//
//  NIOHostingSession.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 19.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

import class Foundation.JSONSerialization

final class NIOHostingSession {
  
  typealias SwiftUIEvent = NIOEndpoint.SwiftUIEvent
  typealias SwiftUIError = NIOEndpoint.SwiftUIError

  let sessionID   : String
  let treeContext : TreeStateContext
  var tree        : HTMLTreeNode
  let rootView    : AnyView

  init<RootView: View>(sessionID: String, view: RootView) {
    self.sessionID = sessionID
    self.rootView  = AnyView(view)
    
    let treeContext = TreeStateContext()

    self.treeContext = treeContext
    
    if debugRequestPhases { print("RP: Build initial tree ...") }
    self.tree = treeContext.currentBuilder.buildTree(for: view, in: treeContext)
    if debugRequestPhases {
      print("RP: Built initial tree:")
      self.tree.dump()
    }
    
    #if DEBUG && false
      self.tree.dump()
    #endif
  }
  
  
  // MARK: - AJAX Event Handler
  
  func handle(event: SwiftUIEvent, response: ServerResponse) throws {

    // takeValuesFromRequest
    
    if let value = event.value {
      if debugRequestPhases { print("RP: taking value: \(value) ..") }
      try tree.takeValue(event.webID, value: value, in: treeContext)
      if debugRequestPhases { print("RP: did take value.") }
    }
    else if debugRequestPhases { print("RP: not taking values ..") }
    
    // invokeAction

    if debugRequestPhases {
      print("RP: invoke: \(event.webID.joined(separator: ".")) ..")
    }
    try tree.invoke(event.webID, in: treeContext)
    if debugRequestPhases { print("RP: did invoke.") }
    
    // check whether the invocation invalidated any components

    if treeContext.invalidComponentIDs.isEmpty {
      // Nothing changed!
      let gottoLoveCodable = [ String : String ]()
      if debugRequestPhases { print("RP: no invalid components, return") }
      return response.json(gottoLoveCodable)
    }
    else if debugRequestPhases {
      print("RP: #\(treeContext.invalidComponentIDs.count) invalid components,",
            "generate changes:")
    }
    
    if debugDumpTrees {
      print("OLD TREE:")
      tree.dump()
      print("-----")
    }

    // generate changes in tree

    var changes = [ HTMLChange ]()
    
    #if false
      // OK, so this is unfortunate, we have the infrastructure to rerender
      // just the invalid component subtrees.
      // But that doesn't play well w/ tree rewriting because the rewriting
      // can overlap with components (which is kinda required functionality).
      // So for now, we just go the worst route and recreate a full new tree :-/
    
      tree.generateChanges(from: tree, into: &changes, in: treeContext)
    #else
      // So for now, we just go the worst route and recreate a full new tree :-/
      let oldTree = tree
      treeContext.clearAllInvalidComponentsPriorTreeRebuild()
      self.tree = treeContext.currentBuilder
                             .buildTree(for: rootView, in: treeContext)
      tree.generateChanges(from: oldTree, into: &changes, in: treeContext)
    #endif
    if debugRequestPhases {
      print("RP: did generate changes: #\(changes.count)")
    }
    
    if debugDumpTrees {
      print("NEW TREE:")
      tree.dump()
      print("-----")
      print("CHANGES:")
      for change in changes {
        print("  ", change)
      }
      print("-----")
    }
    
    // cleanup and deliver
    
    treeContext.clearDiffingStates()
    
    let data = try JSONSerialization.data(withJSONObject: [
      "ok"      : true,
      "changes" : changes.map { $0.jsonObject }
    ])
    
    response.headers.replaceOrAdd(name: "Content-Type",
                                  value: "application/json")
    response.send(data)
    if debugRequestPhases { print("RP: sent.") }
  }
  
  
  // MARK: - Initial HTML Page Generation
  
  func sendInitialPage(to response: ServerResponse) throws {
    var html = ""
    html.reserveCapacity(32000)
    try append(to: &html)
    
    response.headers.replaceOrAdd(
      name: "Content-Type",
      value: "text/html; charset=\"utf-8\""
    )
    response.send(html)
  }
  
  func appendStylesheet(_ name: String, to html: inout String) {
    html += "<link rel='stylesheet' type='text/css' href='/www/\(name)'>"
  }
  func appendScript(_ name: String, to html: inout String) {
    html += "<script language='JavaScript' type='text/javascript'"
    html += " src='/www/\(name)'></script>"
  }
  
  func append(to html: inout String) throws {
    // preamble
    html += "<!DOCTYPE html>\n"
    html += "<html>"; defer { html += "</html>" }
    
    do {
      do {
        html += "<head>"; defer { html += "</head>" }
        appendStylesheet("semantic.min.css", to: &html)
        appendStylesheet("components/icon.min.css", to: &html)
        //components/icon.min.css
        
        // appendScript("jQuery.min.js",   to: &html)
        // appendScript("semantic.min.js", to: &html)

        let gatewayURL = "/handle?wosid=\(sessionID)&wocid=0x1"

        html += "<style>\(SwiftWebUIStyles)</style>\n"
        html += "<script language='JavaScript' type='text/javascript'>\n"
        html +=
          """
          const SwiftUI = {
            sessionID  : "\(sessionID)",
            contextID  : "0x1",
            gatewayURL : "\(gatewayURL)"
          };
          """
        
        html += SwiftWebUIJavaScript
        html += "</script>\n"
      }
      
      do {
        html += "<body>"; defer { html += "</body>" }
        html +=
          """
          <noscript><h2>No JavaScript? That is 1337!</h2></noscript>
          """

        html += "<div class='swiftui-page'>"; defer { html += "</div>" }

        tree.generateHTML(into: &html)
      }
    }
  }
}
