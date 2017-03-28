import XCTest
@testable import QueryKit

class SortDescriptorTests: XCTestCase {
  var attribute:Attribute<Int>!

  override func setUp() {
    super.setUp()
    attribute = Attribute("age")
  }

  func testAscendingSortDescriptor() {
    let sortDescriptor:SortDescriptor<NSManagedObject> = attribute.ascending()
    XCTAssertEqual(sortDescriptor.sortDescriptor, NSSortDescriptor(key: "age", ascending: true))
  }

  func testDescendingSortDescriptor() {
    let sortDescriptor:SortDescriptor<NSManagedObject> = attribute.descending()
    XCTAssertEqual(sortDescriptor.sortDescriptor, NSSortDescriptor(key: "age", ascending: false))
  }
}
