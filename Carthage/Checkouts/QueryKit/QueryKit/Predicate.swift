import Foundation
import CoreData

/// Returns an and predicate from the given predicates
public func && (left: NSPredicate, right: NSPredicate) -> NSPredicate {
  return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [left, right])
}

/// Returns an or predicate from the given predicates
public func || (left: NSPredicate, right: NSPredicate) -> NSPredicate {
  return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [left, right])
}

/// Returns a predicate reversing the given predicate
prefix public func ! (left: NSPredicate) -> NSPredicate {
  return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.not, subpredicates: [left])
}

// MARK: Predicate Type

/// Represents a predicate for a specific model
public struct Predicate<ModelType : NSManagedObject> {
  let predicate:NSPredicate

  init(predicate:NSPredicate) {
    self.predicate = predicate
  }
}

public func == <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
  return Predicate(predicate: left == right)
}

public func != <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
  return Predicate(predicate: left != right)
}

public func > <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
  return Predicate(predicate: left > right)
}

public func >= <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
  return Predicate(predicate: left >= right)
}

public func < <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
  return Predicate(predicate: left < right)
}

public func <= <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
  return Predicate(predicate: left <= right)
}

public func ~= <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
  return Predicate(predicate: left ~= right)
}

public func << <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: [AttributeType]) -> Predicate<T> {
  return Predicate(predicate: left << right)
}

public func << <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: Range<AttributeType>) -> Predicate<T> {
  return Predicate(predicate: left << right)
}

/// Returns an and predicate from the given predicates
public func && <T>(left: Predicate<T>, right: Predicate<T>) -> Predicate<T> {
  return Predicate(predicate: left.predicate && right.predicate)
}

/// Returns an or predicate from the given predicates
public func || <T>(left: Predicate<T>, right: Predicate<T>) -> Predicate<T> {
  return Predicate(predicate: left.predicate || right.predicate)
}

/// Returns a predicate reversing the given predicate
prefix public func ! <T>(predicate: Predicate<T>) -> Predicate<T> {
  return Predicate(predicate: !predicate.predicate)
}
