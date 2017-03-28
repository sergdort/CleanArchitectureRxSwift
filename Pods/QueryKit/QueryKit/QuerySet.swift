import Foundation
import CoreData

/// Represents a lazy database lookup for a set of objects.
open class QuerySet<ModelType : NSManagedObject> : Equatable {
  /// Returns the managed object context that will be used to execute any requests.
  open let context:NSManagedObjectContext

  /// Returns the name of the entity the request is configured to fetch.
  open let entityName:String

  /// Returns the sort descriptors of the receiver.
  open let sortDescriptors:[NSSortDescriptor]

  /// Returns the predicate of the receiver.
  open let predicate:NSPredicate?

  /// The range of the query, allows you to offset and limit a query
  open let range: Range<Int>?

  // MARK: Initialization

  public init(_ context:NSManagedObjectContext, _ entityName:String) {
    self.context = context
    self.entityName = entityName
    self.sortDescriptors = []
    self.predicate = nil
    self.range = nil
  }

  /// Create a queryset from another queryset with a different sortdescriptor predicate and range
  public init(queryset:QuerySet<ModelType>, sortDescriptors:[NSSortDescriptor]?, predicate:NSPredicate?, range: Range<Int>?) {
    self.context = queryset.context
    self.entityName = queryset.entityName
    self.sortDescriptors = sortDescriptors ?? []
    self.predicate = predicate
    self.range = range
  }
}

/// Methods which return a new queryset
extension QuerySet {
  // MARK: Sorting

  /// Returns a new QuerySet containing objects ordered by the given sort descriptor.
  public func orderBy(_ sortDescriptor:NSSortDescriptor) -> QuerySet<ModelType> {
    return orderBy([sortDescriptor])
  }

  /// Returns a new QuerySet containing objects ordered by the given sort descriptors.
  public func orderBy(_ sortDescriptors:[NSSortDescriptor]) -> QuerySet<ModelType> {
    return QuerySet(queryset:self, sortDescriptors:sortDescriptors, predicate:predicate, range:range)
  }

  /// Reverses the ordering of the QuerySet
  public func reverse() -> QuerySet<ModelType> {
    func reverseSortDescriptor(_ sortDescriptor:NSSortDescriptor) -> NSSortDescriptor {
      return NSSortDescriptor(key: sortDescriptor.key!, ascending: !sortDescriptor.ascending)
    }

    return QuerySet(queryset:self, sortDescriptors:sortDescriptors.map(reverseSortDescriptor), predicate:predicate, range:range)
  }

  // MARK: Type-safe Sorting

  ///  Returns a new QuerySet containing objects ordered by the given sort descriptor.
  public func orderBy(_ closure:((ModelType.Type) -> (SortDescriptor<ModelType>))) -> QuerySet<ModelType> {
    return orderBy(closure(ModelType.self).sortDescriptor)
  }

  /// Returns a new QuerySet containing objects ordered by the given sort descriptors.
  public func orderBy(_ closure:((ModelType.Type) -> ([SortDescriptor<ModelType>]))) -> QuerySet<ModelType> {
    return orderBy(closure(ModelType.self).map { $0.sortDescriptor })
  }

  // MARK: Filtering

  /// Returns a new QuerySet containing objects that match the given predicate.
  public func filter(_ predicate:NSPredicate) -> QuerySet<ModelType> {
    var futurePredicate = predicate

    if let existingPredicate = self.predicate {
      futurePredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [existingPredicate, predicate])
    }

    return QuerySet(queryset:self, sortDescriptors:sortDescriptors, predicate:futurePredicate, range:range)
  }

  /// Returns a new QuerySet containing objects that match the given predicates.
  public func filter(_ predicates:[NSPredicate]) -> QuerySet<ModelType> {
    let newPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
    return filter(newPredicate)
  }

  /// Returns a new QuerySet containing objects that exclude the given predicate.
  public func exclude(_ predicate:NSPredicate) -> QuerySet<ModelType> {
    let excludePredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.not, subpredicates: [predicate])
    return filter(excludePredicate)
  }

  /// Returns a new QuerySet containing objects that exclude the given predicates.
  public func exclude(_ predicates:[NSPredicate]) -> QuerySet<ModelType> {
    let excludePredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
    return exclude(excludePredicate)
  }

  // MARK: Type-safe filtering

  /// Returns a new QuerySet containing objects that match the given predicate.
  public func filter(_ closure:((ModelType.Type) -> (Predicate<ModelType>))) -> QuerySet<ModelType> {
    return filter(closure(ModelType.self).predicate)
  }

  /// Returns a new QuerySet containing objects that exclude the given predicate.
  public func exclude(_ closure:((ModelType.Type) -> (Predicate<ModelType>))) -> QuerySet<ModelType> {
    return exclude(closure(ModelType.self).predicate)
  }

  /// Returns a new QuerySet containing objects that match the given predicatess.
  public func filter(_ closures:[((ModelType.Type) -> (Predicate<ModelType>))]) -> QuerySet<ModelType> {
    return filter(closures.map { $0(ModelType.self).predicate })
  }

  /// Returns a new QuerySet containing objects that exclude the given predicates.
  public func exclude(_ closures:[((ModelType.Type) -> (Predicate<ModelType>))]) -> QuerySet<ModelType> {
    return exclude(closures.map { $0(ModelType.self).predicate })
  }
}

/// Functions for evauluating a QuerySet
extension QuerySet {
  // MARK: Subscripting

  /// Returns the object at the specified index.
  public func object(_ index: Int) throws -> ModelType? {
    let request = fetchRequest
    request.fetchOffset = index
    request.fetchLimit = 1
    let items = try context.fetch(request)
    return items.first
  }

  public subscript(range:Range<Int>) -> QuerySet<ModelType> {
    get {
      var fullRange = range

      if let currentRange = self.range {
        fullRange = ((currentRange.lowerBound + range.lowerBound) ..< range.upperBound)
      }

      return QuerySet(queryset:self, sortDescriptors:sortDescriptors, predicate:predicate, range:fullRange)
    }
  }

  // Mark: Getters

  /// Returns the first object in the QuerySet
  public func first() throws -> ModelType? {
    return try self.object(0)
  }

  /// Returns the last object in the QuerySet
  public func last() throws -> ModelType? {
    return try reverse().first()
  }

  // MARK: Conversion

  /// Returns a fetch request equivilent to the QuerySet
  public var fetchRequest: NSFetchRequest<ModelType> {
    let request = NSFetchRequest<ModelType>(entityName: entityName)
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors

    if let range = range {
      request.fetchOffset = range.lowerBound
      request.fetchLimit = range.upperBound - range.lowerBound
    }

    return request
  }

  /// Returns an array of all objects matching the QuerySet
  public func array() throws -> [ModelType] {
    return try context.fetch(fetchRequest)
  }

  // MARK: Count

  /// Returns the count of objects matching the QuerySet.
  public func count() throws -> Int {
    return try context.count(for: fetchRequest)
  }

  // MARK: Exists

  /** Returns true if the QuerySet contains any results, and false if not.
  :note: Returns nil if the operation could not be completed.
  */
  public func exists() throws -> Bool {
    let result:Int = try count()
    return result > 0
  }

  // MARK: Deletion

  /// Deletes all the objects matching the QuerySet.
  public func delete() throws -> Int {
    let objects = try array()
    let deletedCount = objects.count

    for object in objects {
      context.delete(object)
    }

    return deletedCount
  }
}

/// Returns true if the two given querysets are equivilent
public func == <ModelType : NSManagedObject>(lhs: QuerySet<ModelType>, rhs: QuerySet<ModelType>) -> Bool {
  let context = lhs.context == rhs.context
  let entityName = lhs.entityName == rhs.entityName
  let sortDescriptors = lhs.sortDescriptors == rhs.sortDescriptors
  let predicate = lhs.predicate == rhs.predicate
  let startIndex = lhs.range?.lowerBound == rhs.range?.lowerBound
  let endIndex = lhs.range?.upperBound == rhs.range?.upperBound
  return context && entityName && sortDescriptors && predicate && startIndex && endIndex
}
