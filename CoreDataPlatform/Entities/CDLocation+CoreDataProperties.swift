//
//  CDLocation+CoreDataProperties.swift
//  
//
//  Created by Andrey Yastrebov on 10.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CDLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDLocation> {
        return NSFetchRequest<CDLocation>(entityName: "CDLocation");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var address: CDAddress?

}
