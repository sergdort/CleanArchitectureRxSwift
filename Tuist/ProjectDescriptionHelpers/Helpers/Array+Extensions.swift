
extension Array {
    static func build(@ArrayBuilder<Element> _ builder: () -> [Element]) -> [Element] {
        Array(builder())
    }
}

@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildPartialBlock(first: Element) -> [Element] { [first] }
    public static func buildPartialBlock(first: [Element]) -> [Element] { first }
    public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] { accumulated + [next] }
    public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] { accumulated + next }
    
    // Empty Case
    public static func buildBlock() -> [Element] { [] }
    // If/Else
    public static func buildEither(first: [Element]) -> [Element] { first }
    public static func buildEither(second: [Element]) -> [Element] { second }
    // Just ifs
    public static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
    // fatalError()
    public static func buildPartialBlock(first: Never) -> [Element] {}
}
