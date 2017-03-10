#if swift(>=3.0)
  extension Mirror {
    var _superclassMirror: Mirror? {
      return superclassMirror
    }
  }
#else
  public typealias Error = ErrorType
  public typealias ExpressibleByIntegerLiteral = IntegerLiteralConvertible
  public typealias ExpressibleByStringLiteral = StringLiteralConvertible
  
  extension CollectionType {
    func sorted(@noescape by isOrderedBefore: (Self.Generator.Element, Self.Generator.Element) -> Bool) -> [Self.Generator.Element] {
      return sort(isOrderedBefore)
    }
    
    func contains(@noescape where predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Bool {
      return try contains(predicate)
    }
  }
  
  extension CollectionType where Index : RandomAccessIndexType {
    @warn_unused_result
    func reversed() -> ReverseRandomAccessCollection<Self> {
      return reverse()
    }
  }

  extension SequenceType where Generator.Element == String {
    @warn_unused_result
    func joined(separator aSeparator: String) -> String {
      return joinWithSeparator(aSeparator)
    }
  }
  
  extension Array {
    mutating func append<C : CollectionType where C.Generator.Element == Element>(contentsOf newElements: C) {
      appendContentsOf(newElements)
    }
    mutating func append<S : SequenceType where S.Generator.Element == Element>(contentsOf newElements: S) {
      appendContentsOf(newElements)
    }
  }
  
  extension Mirror {
    var _superclassMirror: Mirror? {
      return superclassMirror()
    }
  }
  
  extension String {
    init(describing thing: Any) {
      self.init(thing)
    }
  }
  
#endif

#if _runtime(_ObjC)
  extension String {
    func has(prefix aPrefix: String) -> Bool {
      return hasPrefix(aPrefix)
    }
  }
  
#else
  
  extension String {
    func has(prefix aPrefix: String) -> Bool {
      return aPrefix ==
        String(self.characters.prefix(aPrefix.characters.count))
    }

  }
#endif
