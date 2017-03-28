//
//  QuerySetTests.swift
//  QueryKit
//
//  Created by Kyle Fuller on 06/07/2014.
//
//

import XCTest
import CoreData
import QueryKit


class QuerySetTests: XCTestCase {
  var context:NSManagedObjectContext!
  var queryset:QuerySet<Person>!

  override func setUp() {
    super.setUp()

    context = NSManagedObjectContext()
    context.persistentStoreCoordinator = persistentStoreCoordinator()

    let company = Company.create(context)
    company.name = "Cocode"

    for name in ["Kyle", "Orta", "Ayaka", "Mark", "Scott"] {
      let person = Person.create(context)
      person.name = name

      if name == "Kyle" {
        person.company = company
      }
    }

    try! context.save()

    queryset = QuerySet(context, "Person")
  }

  func testEqualQuerySetIsEquatable() {
    XCTAssertEqual(queryset, QuerySet(context, "Person"))
  }

  // MARK: Sorting

  func testOrderBySortDescriptor() {
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let qs = queryset.orderBy(sortDescriptor)
    XCTAssertTrue(qs.sortDescriptors == [sortDescriptor])
  }

  func testOrderBySortDescriptors() {
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let qs = queryset.orderBy([sortDescriptor])
    XCTAssertTrue(qs.sortDescriptors == [sortDescriptor])
  }

  func testTypeSafeOrderBySortDescriptor() {
    let qs = queryset.orderBy { $0.name.ascending() }
    XCTAssertTrue(qs.sortDescriptors == [NSSortDescriptor(key: "name", ascending: true)])
  }

  func testTypeSafeOrderBySortDescriptors() {
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let qs = queryset.orderBy { [$0.name.ascending()] }
    XCTAssertTrue(qs.sortDescriptors == [sortDescriptor])
  }

  func testReverseOrdering() {
    let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let ageSortDescriptor = NSSortDescriptor(key: "age", ascending: true)
    let qs = queryset.orderBy([nameSortDescriptor, ageSortDescriptor]).reverse()

    XCTAssertEqual(qs.sortDescriptors, [
      NSSortDescriptor(key: "name", ascending: false),
      NSSortDescriptor(key: "age", ascending: false),
    ])
  }

  // MARK: Filtering

  func testFilterPredicate() {
    let predicate = NSPredicate(format: "name == Kyle")
    let qs = queryset.filter(predicate)
    XCTAssertEqual(qs.predicate!, predicate)
  }

  func testFilterPredicates() {
    let predicateName = NSPredicate(format: "name == Kyle")
    let predicateAge = NSPredicate(format: "age > 27")

    let qs = queryset.filter([predicateName, predicateAge])
    XCTAssertEqual(qs.predicate!, NSPredicate(format: "name == Kyle AND age > 27"))
  }

  func testFilterBooleanAttribute() {
    let qs = queryset.filter(Attribute<Bool>("isEmployed"))
    XCTAssertEqual(qs.predicate!, NSPredicate(format: "isEmployed == YES"))
  }

  func testTypeSafeFilter() {
    let qs = queryset.filter { $0.name == "Kyle" }

    XCTAssertEqual(qs.predicate?.description, "name == \"Kyle\"")
  }

  func testTypeSafeFilerEqualWithNilRHS() {
    let qs = queryset.filter { $0.name == nil }
    XCTAssertEqual(qs.predicate?.description, "name == <null>")
  }

  func testTypeSafeRelatedFilterPredicate() {
    let at = Attribute<Company>("company")
    XCTAssertEqual(at.name.key, "company.name")
    let qs = queryset.filter { $0.company.name == "Cocode" }

    XCTAssertEqual(qs.predicate?.description, "company.name == \"Cocode\"")
  }

  // MARK: Exclusion

  func testExcludePredicate() {
    let predicate = NSPredicate(format: "name == Kyle")
    let qs = queryset.exclude(predicate)
    XCTAssertEqual(qs.predicate!, NSPredicate(format: "NOT name == Kyle"))
  }

  func testExcludePredicates() {
    let predicateName = NSPredicate(format: "name == Kyle")
    let predicateAge = NSPredicate(format: "age > 27")

    let qs = queryset.exclude([predicateName, predicateAge])
    XCTAssertEqual(qs.predicate!, NSPredicate(format: "NOT (name == Kyle AND age > 27)"))
  }

  func testExcludeBooleanAttribute() {
    let qs = queryset.exclude(Attribute<Bool>("isEmployed"))
    XCTAssertEqual(qs.predicate!, NSPredicate(format: "isEmployed == NO"))
  }

  func testTypeSafeExclude() {
    let qs = queryset.exclude { $0.name == "Kyle" }

    XCTAssertEqual(qs.predicate?.description, "NOT name == \"Kyle\"")
  }

  // Fetch Request

  func testConversionToFetchRequest() {
    let predicate = NSPredicate(format: "name == Kyle")
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let qs = queryset.filter(predicate).orderBy(sortDescriptor)[2..<4]

    let fetchRequest = qs.fetchRequest

    XCTAssertEqual(fetchRequest.entityName!, "Person")
    XCTAssertEqual(fetchRequest.predicate!, predicate)
    //        XCTAssertEqual(fetchRequest.sortDescriptors!, [sortDescriptor])
    XCTAssertEqual(fetchRequest.fetchOffset, 2)
    XCTAssertEqual(fetchRequest.fetchLimit, 2)
  }

  // MARK: Subscripting

  func testSubscriptingAtIndex() {
    let qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))

    let ayaka = try! qs.object(0)
    let kyle = try! qs.object(1)
    let mark = try! qs.object(2)
    let orta = try! qs.object(3)
    let scott = try! qs.object(4)

    XCTAssertEqual(ayaka!.name, "Ayaka")
    XCTAssertEqual(kyle!.name, "Kyle")
    XCTAssertEqual(mark!.name, "Mark")
    XCTAssertEqual(orta!.name, "Orta")
    XCTAssertEqual(scott!.name, "Scott")
  }

  func testSubscriptingRange() {
    let qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))[0...2]

    XCTAssertEqual(qs.range!.startIndex, 0)
    XCTAssertEqual(qs.range!.endIndex, 3)
  }

  func testSubscriptingRangeSubscriptsCurrentRange() {
    var qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))
    qs = qs[2...5]
    qs = qs[2...4]

    XCTAssertEqual(qs.range!.startIndex, 4)
    XCTAssertEqual(qs.range!.endIndex, 5)
  }

  //  MARK: Getters

  func testFirst() {
    let qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))
    let name = try! qs.first()?.name
    XCTAssertEqual(name, "Ayaka")
  }

  func testLast() {
    let qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))
    let name = try! qs.last()?.name
    XCTAssertEqual(name, "Scott")
  }

  // MARK: Conversion

  func testConversionToArray() {
    let qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))[0...1]
    let people = AssertNotThrow(try qs.array()) ?? []

    XCTAssertEqual(people.count, 2)
  }

  // MARK: Count

  func testCount() {
    let qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))[0...1]
    let count = AssertNotThrow(try qs.count())

    XCTAssertEqual(count!, 2)
  }

  // MARK: Exists

  func testExistsReturnsTrueWithMatchingObjects() {
    let qs = queryset.filter(NSPredicate(format: "name == %@", "Kyle"))
    let exists = AssertNotThrow(try qs.exists()) ?? false

    XCTAssertTrue(exists)
  }

  func testExistsReturnsFalseWithNoMatchingObjects() {
    let qs = queryset.filter(NSPredicate(format: "name == %@", "None"))
    let exists = AssertNotThrow(try qs.exists()) ?? true

    XCTAssertFalse(exists)
  }

  // MARK: Deletion

  func testDelete() {
    let qs = queryset.orderBy(NSSortDescriptor(key: "name", ascending: true))

    let deletedCount = AssertNotThrow(try qs[0...1].delete()) ?? 0
    let count = AssertNotThrow(try qs.count()) ?? 0

    XCTAssertEqual(deletedCount, 2)
    XCTAssertEqual(count, 3)
  }
}
