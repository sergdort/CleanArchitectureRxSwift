//
//  CDCompany+CoreDataProperties.swift
//  
//
//  Created by Andrey Yastrebov on 10.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CDCompany {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCompany> {
        return NSFetchRequest<CDCompany>(entityName: "CDCompany");
    }

    @NSManaged public var name: String?
    @NSManaged public var catchPhrase: String?
    @NSManaged public var bs: String?
    @NSManaged public var user: CDUser?

}
