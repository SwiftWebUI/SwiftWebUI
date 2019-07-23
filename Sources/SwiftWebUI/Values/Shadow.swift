//

public struct Shadow: Hashable {
    public var color: Color, radius: Length, x: Length, y: Length
}

extension Shadow: CSSStyleValue {

    public var cssStringValue: String {
        return "\(radius.cssStringValue) \(x.cssStringValue) \(y.cssStringValue) \(color.cssStringValue)"
    }
}
