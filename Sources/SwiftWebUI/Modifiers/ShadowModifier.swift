//

public extension View {
    func shadow(color: Color = .black, radius: Length, x: Length = 0, y: Length = 0) -> ModifiedContent<Self, ShadowModifier>
    {
        return modifier(ShadowModifier(value: Shadow(color: color, radius: radius, x: x, y: y)))
    }
}

public struct ShadowModifier: ViewModifier {
    public typealias Value = Shadow
    
    let value : Value
    
    public func buildTree<T: View>(for view: T, in context: TreeStateContext)
                  -> HTMLTreeNode
      {
        context.appendContentElementIDComponent()
        let child = context.currentBuilder.buildTree(for: view, in: context)
        context.deleteLastElementIDComponent()
        
        return HTMLShadowNode(elementID: context.currentElementID,
                              value: value, content: child)
      }
}
