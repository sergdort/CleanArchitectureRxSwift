//
//  AttributeTests.swift
//  QueryKit
//
//  Created by Kyle Fuller on 19/06/2014.
//
//

import XCTest
import QueryKit

class AttributeTests: XCTestCase {
  var attribute:Attribute<Int>!

  override func setUp() {
    super.setUp()
    attribute = Attribute("age")
  }

  func testAttributeHasKey() {
    XCTAssertEqual(attribute.key, "age")
  }

  func testAttributeExpression() {
    XCTAssertEqual(attribute.expression.keyPath, "age")
  }

  func testEqualAttributesAreEquatable() {
    XCTAssertEqual(attribute, Attribute<Int>("age"))
  }

  func testCompoundAttributeCreation() {
    let personCompanyNameAttribute = Attribute<NSString>(attributes:["company", "name"])

    XCTAssertEqual(personCompanyNameAttribute.key, "company.name")
    XCTAssertEqual(personCompanyNameAttribute.expression.keyPath, "company.name")
  }

  // Sorting

  func testAscendingSortDescriptor() {
    XCTAssertEqual(attribute.ascending(), NSSortDescriptor(key: "age", ascending: true))
  }

  func testDescendingSortDescriptor() {
    XCTAssertEqual(attribute.descending(), NSSortDescriptor(key: "age", ascending: false))
  }

  // Operators

  func testEqualityOperator() {
    let predicate:NSPredicate = (attribute == 10)
    XCTAssertEqual(predicate, NSPredicate(format:"age == 10"))
  }

  func testInequalityOperator() {
    let predicate:NSPredicate = (attribute != 10)
    XCTAssertEqual(predicate, NSPredicate(format:"age != 10"))
  }

  func testGreaterThanOperator() {
    let predicate:NSPredicate = (attribute > 10)
    XCTAssertEqual(predicate, NSPredicate(format:"age > 10"))
  }

  func testGreaterOrEqualThanOperator() {
    let predicate:NSPredicate = (attribute >= 10)
    XCTAssertEqual(predicate, NSPredicate(format:"age >= 10"))
  }

  func testLessThanOperator() {
    let predicate:NSPredicate = (attribute < 10)
    XCTAssertEqual(predicate, NSPredicate(format:"age < 10"))
  }

  func testLessOrEqualThanOperator() {
    let predicate:NSPredicate = (attribute <= 10)
    XCTAssertEqual(predicate, NSPredicate(format:"age <= 10"))
  }

  func testLikeOperator() {
    let predicate:NSPredicate = (attribute ~= 10)
    XCTAssertEqual(predicate, NSPredicate(format:"age LIKE 10"))
  }

  func testInOperator() {
    let predicate:NSPredicate = (attribute << [5, 10])
    XCTAssertEqual(predicate, NSPredicate(format:"age IN %@", [5, 10]))
  }

  func testBetweenRangeOperator() {
    let predicate:NSPredicate = attribute << (5..<10)
    XCTAssertEqual(predicate, NSPredicate(format:"age BETWEEN %@", [5, 10]))
  }

  func testOptionalEqualityOperator() {
    let attribute = Attribute<String?>("name")
    let predicate:NSPredicate = (attribute == "kyle")
    XCTAssertEqual(predicate, NSPredicate(format:"name == 'kyle'"))
  }

  func testOptionalNSObjectEqualityOperator() {
    let attribute = Attribute<NSString?>("name")
    let predicate:NSPredicate = (attribute == "kyle")
    XCTAssertEqual(predicate, NSPredicate(format:"name == 'kyle'"))
  }

  func testEqualityOperatorWithNilRHS() {
    let attribute = Attribute<String?>("name")
    let predicate: NSPredicate = attribute == nil
    XCTAssertEqual(predicate.description, "name == <null>")
  }
}

class CollectionAttributeTests: XCTestCase {
  func testCountOfSet() {
    let setAttribute = Attribute<NSSet>("names")
    let countAttribute = count(setAttribute)
    XCTAssertEqual(countAttribute, Attribute<Int>("names.@count"))
  }

  func testCountOfOrderedSet() {
    let setAttribute = Attribute<NSOrderedSet>("names")
    let countAttribute = count(setAttribute)
    XCTAssertEqual(countAttribute, Attribute<Int>("names.@count"))
  }
}

class BoolAttributeTests: XCTestCase {
  var attribute:Attribute<Bool>!

  override func setUp() {
    super.setUp()
    attribute = Attribute("hasName")
  }

  func testNotAttributeReturnsPredicate() {
    XCTAssertEqual(!attribute, NSPredicate(format:"hasName == NO"))
  }
}
