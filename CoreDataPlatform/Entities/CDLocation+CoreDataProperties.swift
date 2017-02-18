//
//  CDLocation+CoreDataProperties.swift
//  NetworkAndSecurity
//
//  Created by sergdort on 07/01/2017.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDLocation> {
        return NSFetchRequest<CDLocation>(entityName: "CDLocation");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var uid: String?
    @NSManaged public var post: CDPost?

}
