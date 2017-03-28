import Foundation
import CoreData

/// Represents a sort descriptor for a specific model
public struct SortDescriptor<ModelType : NSManagedObject> {
  let sortDescriptor:NSSortDescriptor

  init(sortDescriptor:NSSortDescriptor) {
    self.sortDescriptor = sortDescriptor
  }
}

extension Attribute {
  /// Returns an ascending sort descriptor for the attribute
  public func ascending<T : NSManagedObject>() -> SortDescriptor<T> {
    return SortDescriptor(sortDescriptor: ascending())
  }

  /// Returns a descending sort descriptor for the attribute
  public func descending<T : NSManagedObject>() -> SortDescriptor<T> {
    return SortDescriptor(sortDescriptor: descending())
  }
}
