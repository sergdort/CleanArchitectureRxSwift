//
//  PredicateTests.swift
//  QueryKit
//
//  Created by Kyle Fuller on 19/06/2014.
//
//

import XCTest
@testable import QueryKit


class NSPredicateTests: XCTestCase {
  var namePredicate = NSPredicate(format: "name == Kyle")
  var agePredicate = NSPredicate(format: "age >= 21")

  func testAndPredicate() {
    let predicate = namePredicate && agePredicate
    XCTAssertEqual(predicate, NSPredicate(format: "name == Kyle AND age >= 21"))
  }

  func testOrPredicate() {
    let predicate = namePredicate || agePredicate
    XCTAssertEqual(predicate, NSPredicate(format: "name == Kyle OR age >= 21"))
  }

  func testNotPredicate() {
    let predicate = !namePredicate
    XCTAssertEqual(predicate, NSPredicate(format: "NOT name == Kyle"))
  }
}


class PredicateTests: XCTestCase {
  var attribute:Attribute<Int>!

  override func setUp() {
    super.setUp()
    attribute = Attribute("age")
  }

  // MARK: Operators

  func testEqualityOperator() {
    let predicate:Predicate<NSManagedObject> = attribute == 10
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age == 10"))
  }

  func testEqualityOperatorWithNilRHS() {
    let attribute = Attribute<String?>("name")
    let predicate: Predicate = attribute == nil
    XCTAssertEqual(predicate.predicate.description, "name == <null>")
  }

  func testInequalityOperator() {
    let predicate:Predicate<NSManagedObject> = (attribute != 10)
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age != 10"))
  }

  func testGreaterThanOperator() {
    let predicate:Predicate<NSManagedObject> = (attribute > 10)
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age > 10"))
  }

  func testGreaterOrEqualThanOperator() {
    let predicate:Predicate<NSManagedObject> = (attribute >= 10)
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age >= 10"))
  }

  func testLessThanOperator() {
    let predicate:Predicate<NSManagedObject> = (attribute < 10)
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age < 10"))
  }

  func testLessOrEqualThanOperator() {
    let predicate:Predicate<NSManagedObject> = (attribute <= 10)
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age <= 10"))
  }

  func testLikeOperator() {
    let predicate:Predicate<NSManagedObject> = (attribute ~= 10)
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age LIKE 10"))
  }

  func testInOperator() {
    let predicate:Predicate<NSManagedObject> = (attribute << [5, 10])
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age IN %@", [5, 10]))
  }

  func testBetweenRangeOperator() {
    let predicate:Predicate<NSManagedObject> = attribute << (5..<10)
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"age BETWEEN %@", [5, 10]))
  }

  func testNSObjectEqualityOperator() {
    let attribute = Attribute<NSString>("name")
    let predicate:Predicate<NSManagedObject> = (attribute == "kyle")
    XCTAssertEqual(predicate.predicate, NSPredicate(format:"name == 'kyle'"))
  }

  // MARK:

  var namePredicate = Predicate<NSManagedObject>(predicate: NSPredicate(format: "name == Kyle"))
  var agePredicate = Predicate<NSManagedObject>(predicate: NSPredicate(format: "age >= 21"))

  func testAndPredicate() {
    let predicate = namePredicate && agePredicate
    XCTAssertEqual(predicate.predicate, NSPredicate(format: "name == Kyle AND age >= 21"))
  }

  func testOrPredicate() {
    let predicate = namePredicate || agePredicate
    XCTAssertEqual(predicate.predicate, NSPredicate(format: "name == Kyle OR age >= 21"))
  }

  func testNotPredicate() {
    let predicate = !namePredicate
    XCTAssertEqual(predicate.predicate, NSPredicate(format: "NOT name == Kyle"))
  }
}
