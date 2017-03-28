//
//  QueryKitTests.swift
//  QueryKitTests
//
//  Created by Kyle Fuller on 19/06/2014.
//
//

import XCTest
import QueryKit
import CoreData

@objc(Person) class Person : NSManagedObject {
  @NSManaged var name:String
  @NSManaged var company:Company?

  class var entityName:String {
    return "Person"
  }

  class var name:Attribute<String> {
    return Attribute("name")
  }

  class var company:Attribute<Company> {
    return Attribute("company")
  }
}

@objc(Company) class Company : NSManagedObject {
  @NSManaged var name:String

  class var entityName:String {
    return "Company"
  }

  class var name:Attribute<String> {
    return Attribute("name")
  }

  class func create(_ context:NSManagedObjectContext) -> Company {
    return NSEntityDescription.insertNewObject(forEntityName: Company.entityName, into: context) as! Company
  }
}

extension Attribute where AttributeType: Company {
  var name:Attribute<String> {
    return attribute(AttributeType.name)
  }
}

extension Person {
  class func create(_ context:NSManagedObjectContext) -> Person {
    return NSEntityDescription.insertNewObject(forEntityName: Person.entityName, into: context) as! Person
  }
}

func managedObjectModel() -> NSManagedObjectModel {
  let companyEntity = NSEntityDescription()
  companyEntity.name = Company.entityName
  companyEntity.managedObjectClassName = "Company"

  let personEntity = NSEntityDescription()
  personEntity.name = Person.entityName
  personEntity.managedObjectClassName = "Person"

  let companyNameAttribute = NSAttributeDescription()
  companyNameAttribute.name = "name"
  companyNameAttribute.attributeType = NSAttributeType.stringAttributeType
  companyNameAttribute.isOptional = false

  let companyPeopleAttribute = NSRelationshipDescription()
  companyPeopleAttribute.name = "members"
  companyPeopleAttribute.maxCount = 0
  companyPeopleAttribute.destinationEntity = personEntity

  let personNameAttribute = NSAttributeDescription()
  personNameAttribute.name = "name"
  personNameAttribute.attributeType = NSAttributeType.stringAttributeType
  personNameAttribute.isOptional = false

  let personCompanyRelation = NSRelationshipDescription()
  personCompanyRelation.name = "company"
  personCompanyRelation.destinationEntity = companyEntity
  personCompanyRelation.maxCount = 1
  personCompanyRelation.isOptional = true

  companyPeopleAttribute.inverseRelationship = personCompanyRelation
  personCompanyRelation.inverseRelationship = companyPeopleAttribute

  companyEntity.properties = [companyNameAttribute, companyPeopleAttribute]
  personEntity.properties = [personNameAttribute, personCompanyRelation]

  let model = NSManagedObjectModel()
  model.entities = [personEntity, companyEntity]

  return model
}

func persistentStoreCoordinator() -> NSPersistentStoreCoordinator {
  let model = managedObjectModel()
  let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
  do {
    try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
  } catch {
    print(error)
    fatalError()
  }
  return persistentStoreCoordinator
}

public func AssertNotThrow<R>(_ closure: @autoclosure () throws -> R) -> R? {
  var result: R?
  AssertNotThrow() {
    result = try closure()
  }
  return result
}

public func AssertNotThrow(_ closure: () throws -> ()) {
  do {
    try closure()
  } catch let error {
    XCTFail("Catched error \(error), "
      + "but did not expect any error.")
  }
}
