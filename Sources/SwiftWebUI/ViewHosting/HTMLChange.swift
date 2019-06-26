//
//  HTMLChange.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 16.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

public enum HTMLChange {
  
  init(_ webID: String, toggle clazz: String, isEnabled: Bool) {
    if isEnabled { self = .addClass   (webID: webID, class: clazz) }
    else         { self = .removeClass(webID: webID, class: clazz) }
  }
  
  case replaceElementWithHTML        (webID: String, html: String)
  case replaceElementContentsWithHTML(webID: String, html: String)
  case deleteElement                 (webID: String)
  case insertElementWithHTML         (webID: String, after: String?,
                                      html: String)
  case setAttribute                  (webID: String,
                                      attribute: String, value: String)
  case removeAttribute               (webID: String, attribute: String)
  case addClass                      (webID: String, class: String)
  case removeClass                   (webID: String, class: String)

  case order(webID: String, after: String?)

  case selectOneOption(selectID: String, optionID: String)
  
  var jsonObject : [ String : Any ] {
    switch self {
      case .replaceElementWithHTML(let webID, let html):
        return [ "type": "replace-element", "id": webID, "content": html ]
      case .replaceElementContentsWithHTML(let webID, let html):
        return [ "type": "replace-content", "id": webID, "content": html ]

      case .addClass(let webID, let clazz):
        return [ "type": "add-class", "id": webID, "content": clazz ]
      case .removeClass(let webID, let clazz):
        return [ "type": "remove-class", "id": webID, "content": clazz ]

      case .insertElementWithHTML(let webID, let after, let html):
        if let after = after {
          return [ "type": "insert-element", "id": after, "newID": webID,
                   "content": html ]
        }
        else {
          return [ "type": "insert-element", "newID": webID, "content": html ]
        }
      
      case .order(let webID, let after):
        if let after = after {
          return [ "type": "order-child", "id": webID, "after": after ]
        }
        else {
          return [ "type": "order-child", "id": webID ]
        }

      case .deleteElement(let webID):
        return [ "type": "delete-element", "id": webID ]
      
      
      case .setAttribute(let webID, let attribute, let value):
        return [ "type": "set-attribute", "id": webID,
                 "attribute": attribute, "content": value ]
      case .removeAttribute(let webID, let attribute):
        return [ "type": "delete-attribute", "id": webID,
                 "attribute": attribute ]

      case .selectOneOption(let selectID, let optionID):
        return [ "type": "select-one-option", "id": selectID,
                 "option": optionID ]

    }
  }
}
