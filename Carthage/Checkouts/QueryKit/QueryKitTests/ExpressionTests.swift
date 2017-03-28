//
//  ExpressionTests.swift
//  QueryKit
//
//  Created by Kyle Fuller on 06/07/2014.
//
//

import XCTest
import QueryKit

class ExpressionTests: XCTestCase {
  var leftHandSide:NSExpression!
  var rightHandSide:NSExpression!

  override func setUp() {
    super.setUp()

    leftHandSide = NSExpression(forKeyPath: "age")
    rightHandSide = NSExpression(forConstantValue: 10)
  }

  func testEqualityOperator() {
    XCTAssertEqual(leftHandSide == rightHandSide, NSPredicate(format:"age == 10"))
  }

  func testInequalityOperator() {
    XCTAssertEqual(leftHandSide != rightHandSide, NSPredicate(format:"age != 10"))
  }

  func testGreaterThanOperator() {
    let predicate:NSPredicate = leftHandSide > rightHandSide
    XCTAssertEqual(predicate, NSPredicate(format:"age > 10"))
  }

  func testGreaterOrEqualThanOperator() {
    XCTAssertEqual(leftHandSide >= rightHandSide, NSPredicate(format:"age >= 10"))
  }

  func testLessThanOperator() {
    XCTAssertEqual(leftHandSide < rightHandSide, NSPredicate(format:"age < 10"))
  }

  func testLessOrEqualThanOperator() {
    XCTAssertEqual(leftHandSide <= rightHandSide, NSPredicate(format:"age <= 10"))
  }

  func testLikeOperator() {
    XCTAssertEqual(leftHandSide ~= rightHandSide, NSPredicate(format:"age LIKE 10"))
  }

  func testInOperator() {
    XCTAssertEqual(leftHandSide << rightHandSide, NSPredicate(format:"age IN 10"))
  }
}
