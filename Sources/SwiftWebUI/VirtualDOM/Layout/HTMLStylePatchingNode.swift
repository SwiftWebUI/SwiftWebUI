//
//  File.swift
//  
//
//  Created by SamuelIH on 9/15/20.
//

import Foundation

/// A node used to patch styles on an existing tree.
///
/// This node is generally used for "visual" modifiers such as `shadow` and `backgroundColor`, because these affect visual appearances and not frame layout.
/// Rather then directly initializing this struct, consider using the static `patch` function, as it will automatically hook in to existing style patching nodes:
///
///     // from ShadowModifier.swift
///     return HTMLStylePatchingNode.patch
///     (
///       child,
///       withStyles   : [.boxShadow : value],
///       andElementID : context.currentElementID
///     )
struct HTMLStylePatchingNode: HTMLWrappingNode {
    
    let elementID : ElementID
    var value     : CSSStyles
    let content   : HTMLTreeNode
    
    
    /// Patches the existing node with the new styles provided
    ///
    /// This function will wrap  the `node` with an `HTMLStylePatchingNode` and patch in the new styles. However, if the `node` is *already* an `HTMLStylePatchingNode`, it will attempt to combine the styles into one node. Please note that if the existing styles conflict with the new ones provided, this will create a **new** style patching node, and wrap it around the existing one.
    /// - Parameters:
    ///   - node: The node to be wrapped. It may not be wrapped if it's already an `HTMLStylePatchingNode`
    ///   - withStyles: The styles to patch it with
    /// - Returns: An `HTMLStylePatchingNode` either a new one or a merged, existing one.
    static func patch(_ node: HTMLTreeNode, withStyles: CSSStyles, andElementID elementID: ElementID) -> HTMLStylePatchingNode {
        
        if var existingPatch = node as? HTMLStylePatchingNode {
            if !existingPatch.value.keys.contains(where: withStyles.keys.contains) {
                // no conflict between the two patch nodes
                // now we merge them
                existingPatch.value = existingPatch.value.merging(withStyles) { (_, new) in new }
                return existingPatch
            }
        }
        
        return HTMLStylePatchingNode(elementID: elementID, value: withStyles, content: node)
    }
    
    func nodeByApplyingNewContent(_ newContent: HTMLTreeNode) -> Self {
        return HTMLStylePatchingNode(elementID: elementID, value: value, content: newContent)
    }
    
    public func dump(nesting: Int) {
        let indent = String(repeating: "  ", count: nesting)
        let info =
            value.map { (k,v) in
                return " \(k.rawValue)=\(v.cssStringValue)"
            }
            .joined()
        
        print("\(indent)<StylePatch: \(elementID) \(info)>")
        content.dump(nesting: nesting + 1)
        print("\(indent)</StylePatch>")
    }
    
    func generateHTML(into html: inout String) {
        html += "<div"
        html.appendAttribute("id", elementID.webID)
        if let v = value.cssStringValue { html.appendAttribute("style", v) }
        html += ">"
        
        defer { html += "</div>" }
        
        content.generateHTML(into: &html)
    }
    
    func generateChanges(from   oldNode : HTMLTreeNode,
                         into changeset : inout [ HTMLChange ],
                         in     context : TreeStateContext)
    {
        guard let oldNode = sameType(oldNode, &changeset) else { return }
        
        if oldNode.value.cssStringValue != value.cssStringValue {
            changeset.append(.setAttribute(webID: elementID.webID, attribute: "style",
                                           value: value.cssStringValue ?? ""))
        }

        content.generateChanges(from: oldNode.content, into: &changeset,
                                in: context)
    }
}
