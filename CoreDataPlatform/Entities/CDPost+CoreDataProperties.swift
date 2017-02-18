//
//  CDPost+CoreDataProperties.swift
//  NetworkAndSecurity
//
//  Created by sergdort on 07/01/2017.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPost> {
        return NSFetchRequest<CDPost>(entityName: "CDPost");
    }

    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var updateDate: NSDate?
    @NSManaged public var uid: String?
    @NSManaged public var media: CDMedia?
    @NSManaged public var location: CDLocation?

}
