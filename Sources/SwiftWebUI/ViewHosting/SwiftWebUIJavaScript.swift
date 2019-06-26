//
//  SwiftWebUIJavaScript.swift
//  SwiftWebUI
//
//  Created by Helge Heß on 14.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// TODO: We should just open a WebSocket connection, that would even allow
//       server side updates (e.g. from timers).

let SwiftWebUIJavaScript =
"""
SwiftUI.handleJSON = function(json) {
  if (json.changes !== undefined) {
    for (var i = 0; i < json.changes.length; i++) {
      const change  = json.changes[i];
      const element = document.getElementById(change.id);

      console.log("APPLY CHANGE:", change.type, change);
      switch (change.type) {
        case "replace-element":
          if (element) { element.outerHTML = change.content; }
          else { console.error("Missing element for change:", change.id); }
          break;
        case "replace-content":
          if (element) { element.innerHTML = change.content; }
          else { console.error("Missing element for change:", change.id); }
          break;
        case "delete-element":
          if (element) { element.remove() }
          else { console.error("Missing element for change:", change.id); }
          break;

        case "insert-element":
          const t = document.createElement("template");
          t.innerHTML = change.content;
          const r = t.content.cloneNode(true);
          const pred = element
                     ? element.nextSibling
                     : element.parentNode.firstChild;
          element.parentNode.insertBefore(r, pred);
          break;

        case "order-child":
          if (element) {
            const afterElement = document.getElementById(change.after);
            const pred = afterElement
                       ? afterElement.nextSibling
                       : element.parentNode.firstChild;
            element.parentNode.insertBefore(element, pred);
          }
          else { console.error("Missing element for change:", change.id); }
          break;

        case "set-attribute":
          if (element) {
            element.setAttribute(change.attribute, change.content);
          }
          else { console.error("Missing element for change:", change.id); }
          break;
        case "delete-attribute":
          if (element) { element.removeAttribute(change.attribute); }
          else { console.error("Missing element for change:", change.id); }
        break;

        case "add-class":
          if (element) { element.classList.add(change.content); }
          else { console.error("Missing element for change:", change.id); }
          break;
        case "remove-class":
          if (element) { element.classList.remove(change.content); }
          else { console.error("Missing element for change:", change.id); }
          break;

        case "select-one-option":
          if (element) {
            element.value = change.option;
          }
          else { console.error("Missing element for change:", change.id); }
          break;

        default:
          console.log("Unexpected change:", change);
      }
    }
  }
}

SwiftUI.sendEvent = function(type, elementID, value) {
  // TODO: convert to send stuff as JSON in body ...
  const self = this;
  var url = self.gatewayURL + "&eid=" + elementID + "&event=" + type;
  if (value !== undefined) {
    url += "&value=" + encodeURIComponent(value);
  }
  console.log("URL:", url);
  
  fetch(url, { method: "POST", cache: "no-cache" })
    .then(response => response.json())
    .then(self.handleJSON)
    .catch(function(error) {
      alert("Ooops, failed?!\\n" + error);
    })
};

SwiftUI.valueCommit = function(element) {
  const self = this;
  console.log("commit element:", element);
  this.sendEvent("commit", element.id + ".commit", element.value);
};
SwiftUI.valueChanged = function(element) {
  // TODO: we need to debounce those!!! But technically this requires a queue
  //       so that commits do not come in before change events.
  console.log("changed element:", element);
  this.sendEvent("commit", element.id + ".change", element.value);
};
SwiftUI.checkboxChanged = function(element) {
  console.log("checkbox element:", element);
  this.sendEvent("click", element.id, element.checked ? "on" : "off");
};
SwiftUI.selectChanged = function(element, event) {
  console.log("option element clicked:", event.target.value);
  this.sendEvent("click", event.target.value);
};
SwiftUI.radioChanged = function(element, event) {
  console.log("radio element clicked:", event.target.value);
  this.sendEvent("click", event.target.value);
};
SwiftUI.click = function(element,event) {
  if (event) { event.stopPropagation(); }
  console.log("clicked element:", element,event);
  this.sendEvent("click", element.id);
};

SwiftUI.tabClick = function(tabItem,event) {
  const self = this;
  console.log("clicked tabitem:", tabItem);
  if (event) { event.stopPropagation(); }
  const element = document.getElementById(tabItem.getAttribute("data-tab"));
  if (element) {
    function dropClassFromChildren(node, clazz) {
      var child = node.firstChild;
      while (child) {
        if (child !== this && child.nodeType === Node.ELEMENT_NODE) {
          child.classList.remove(clazz);
        }
        child = child.nextSibling;
      }
    }
    dropClassFromChildren(element.parentNode, "active");
    dropClassFromChildren(tabItem.parentNode, "active");
    tabItem.classList.add("active");
    element.classList.add("active");
  }
  else { console.error("Missing tab content:", tabItem) }
};
"""
