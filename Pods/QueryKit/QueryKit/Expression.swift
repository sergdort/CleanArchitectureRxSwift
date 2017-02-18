import Foundation

/// Returns an equality predicate for the two given expressions
public func == (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.equalTo, options: NSComparisonPredicate.Options(rawValue: 0))
}

/// Returns an inequality predicate for the two given expressions
public func != (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.notEqualTo, options: NSComparisonPredicate.Options(rawValue: 0))
}

public func > (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.greaterThan, options: NSComparisonPredicate.Options(rawValue: 0))
}

public func >= (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.greaterThanOrEqualTo, options: NSComparisonPredicate.Options(rawValue: 0))
}

public func < (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.lessThan, options: NSComparisonPredicate.Options(rawValue: 0))
}

public func <= (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.lessThanOrEqualTo, options: NSComparisonPredicate.Options(rawValue: 0))
}

public func ~= (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.like, options: NSComparisonPredicate.Options(rawValue: 0))
}

public func << (left: NSExpression, right: NSExpression) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.in, options: NSComparisonPredicate.Options(rawValue: 0))
}
