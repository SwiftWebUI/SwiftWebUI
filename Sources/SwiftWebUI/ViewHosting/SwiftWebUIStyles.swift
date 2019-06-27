//
//  SwiftWebUIStyles.swift
//  TestXcodeSPM
//
//  Created by Helge Heß on 09.06.19.
//  Copyright © 2019 Helge Heß. All rights reserved.
//

// https://developer.mozilla.org/en-US/docs/Web/CSS/Adjacent_sibling_combinator
// https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties

// Note:
// I need a lot of help with those :-)
// FIXME:
// - This overrides some of the SemanticUI styles (hence the !important),
//   replace w/ proper more specific selectors.

let SwiftWebUIStyles =
"""
html, body {
  height: 100%;
}
.swiftui-page {
  /* TBD: position : absolute; */
  width           : 100%;
  height          : 100vh;
  display         : flex;
  flex-direction  : column;
  align-items     : center;
  justify-content : center;
}

.swiftui-bg {
  padding-top:    2px;
  padding-bottom: 2px;
}

.swiftui-frame {
  display: flex;
}

.swiftui-padder {
  padding: 0.5rem 0.5rem 0.5rem 0.5rem;
}

.swiftui-scroll {
  overflow-y: scroll;
}

.swiftui-click-container.active {
  cursor: pointer;
}

.swiftui-list {
  overflow-y: auto;
  height:     100%;
}
.swiftui-list.selectable > .item.selectable:hover {
  background-color: #FAFAFA;
  cursor: pointer;
}
.swiftui-list > .item {
  padding-left   : 0.5rem !important;
  padding-right  : 0.5rem !important;
}
.swiftui-list > .item:first-child {
  padding-top    : 0.5rem !important;
}
.swiftui-list > .item:last-child {
  padding-bottom : 0.5rem !important;
}
.swiftui-list > .item.active {
  background-color: #EEE;
  border-color: 1px solid #DEDEDE;
}
div.swiftui-list > div.item > div.swiftui-stack > button.ui.button,
div.swiftui-list > div.item > button.ui.button
{
  width: 100%;
  text-color: initial;
  text-align: left;
  background-color: initial;
  padding: 0;
}
div.swiftui-list > div.item > div.swiftui-stack > button.ui.button.active,
div.swiftui-list > div.item > button.ui.button.active
{
  background-color: #FAFAFA;
}

.swiftui-navigation {
  display        : flex;
  flex-direction : row;
  align-items    : stretch;
  border         : 1px solid rgba(34, 36, 38, .15);
  border-radius  : .28571429rem; /* SemanticUI :-) */
}
.swiftui-navigation .swiftui-nav-sidebar {
  flex-grow      : 1;
  border-right   : 1px solid rgba(34, 36, 38, .15);
  width          : 30%;
}
.swiftui-navigation .swiftui-nav-content {
  flex-grow      : 10;
}

.swiftui-stack {
  display: flex;
}
.swiftui-vstack {
  flex-direction: column;
  --swiftui-vpadding: 0.3em;
}
.swiftui-hstack {
  flex-direction: row;
  --swiftui-hpadding: 0.6em;
}
.swiftui-stack .swiftui-spacer { flex-grow: 99; }
.swiftui-vstack > * + * {
  margin-top:  var(--swiftui-vpadding) !important; /* SUI also sets this */
}
.swiftui-hstack > * + * {
  margin-left: var(--swiftui-hpadding) !important;
}

.swiftui-vstack > .ui.divider {
  width: 100%;
}
.swiftui-hstack > .ui.divider {
  height: 100%;
}

.swiftui-text {
  font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue",
               Arial, Helvetica, sans-serif;
}

.swiftui-italic { font-style:  italic; }
.swiftui-bold   { font-weight: bold;   }
.swiftui-body {
  font-size: 1rem;
}
.swiftui-body {
  font-size: 1rem;
}
.swiftui-title {
  font-size: 1.2rem;
}
.swiftui-large-title {
  font-size: 1.6rem;
}
.swiftui-headline {
  font-size: 1.2rem;
}
.swiftui-subheadline {
  font-size: 0.8rem;
}


.ui.label > div.swiftui-text {
  display: inline;
}
label > div.swiftui-text {
  display: inline;
}
div.swiftui-radio {
  display:        flex;
  flex-direction: row;
  align-items:    center;
}
div.swiftui-radio input {
  margin-right: 0.4rem;
}
"""

