import Foundation

/// An attribute, representing an attribute on a model
public struct Attribute<AttributeType> : Equatable {
  public let key:String

  public init(_ key:String) {
    self.key = key
  }

  /// Builds a compound attribute with other key paths
  public init(attributes:[String]) {
    self.init(attributes.joined(separator: "."))
  }

  /// Returns an expression for the attribute
  public var expression:NSExpression {
    return NSExpression(forKeyPath: key)
  }

  // MARK: Sorting

  /// Returns an ascending sort descriptor for the attribute
  public func ascending() -> NSSortDescriptor {
    return NSSortDescriptor(key: key, ascending: true)
  }

  /// Returns a descending sort descriptor for the attribute
  public func descending() -> NSSortDescriptor {
    return NSSortDescriptor(key: key, ascending: false)
  }

  func expressionForValue(_ value:AttributeType?) -> NSExpression {
    if let value = value {
      if let value = value as? NSObject {
        return NSExpression(forConstantValue: value as NSObject)
      }

      if MemoryLayout<AttributeType>.size == MemoryLayout<uintptr_t>.size {
        let value = unsafeBitCast(value, to: Optional<NSObject>.self)
        if let value = value {
          return NSExpression(forConstantValue: value)
        }
      }

      let value = unsafeBitCast(value, to: Optional<String>.self)
      if let value = value {
        return NSExpression(forConstantValue: value)
      }
    }

    return NSExpression(forConstantValue: NSNull())
  }

  /// Builds a compound attribute by the current attribute with the given attribute
  public func attribute<T>(_ attribute:Attribute<T>) -> Attribute<T> {
    return Attribute<T>(attributes: [key, attribute.key])
  }
}


/// Returns true if two attributes have the same name
public func == <AttributeType>(lhs: Attribute<AttributeType>, rhs: Attribute<AttributeType>) -> Bool {
  return lhs.key == rhs.key
}

public func == <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
  return left.expression == left.expressionForValue(right)
}

public func != <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
  return left.expression != left.expressionForValue(right)
}

public func > <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
  return left.expression > left.expressionForValue(right)
}

public func >= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
  return left.expression >= left.expressionForValue(right)
}

public func < <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
  return left.expression < left.expressionForValue(right)
}

public func <= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
  return left.expression <= left.expressionForValue(right)
}

public func ~= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> NSPredicate {
  return left.expression ~= left.expressionForValue(right)
}

public func << <AttributeType>(left: Attribute<AttributeType>, right: [AttributeType]) -> NSPredicate {
    let value = right.map { value in return value as! NSObject }
    return left.expression << NSExpression(forConstantValue: value)
}

public func << <AttributeType>(left: Attribute<AttributeType>, right: Range<AttributeType>) -> NSPredicate {
    let value = [right.lowerBound as! NSObject, right.upperBound as! NSObject] as NSArray
    let rightExpression = NSExpression(forConstantValue: value)

  return NSComparisonPredicate(leftExpression: left.expression, rightExpression: rightExpression, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.between, options: NSComparisonPredicate.Options(rawValue: 0))
}

/// MARK: Bool Attributes

prefix public func ! (left: Attribute<Bool>) -> NSPredicate {
  return left == false
}

public extension QuerySet {
  public func filter(_ attribute:Attribute<Bool>) -> QuerySet<ModelType> {
    return filter(attribute == true)
  }

  public func exclude(_ attribute:Attribute<Bool>) -> QuerySet<ModelType> {
    return filter(attribute == false)
  }
}

// MARK: Collections

public func count(_ attribute:Attribute<NSSet>) -> Attribute<Int> {
  return Attribute<Int>(attributes: [attribute.key, "@count"])
}

public func count(_ attribute:Attribute<NSOrderedSet>) -> Attribute<Int> {
  return Attribute<Int>(attributes: [attribute.key, "@count"])
}
