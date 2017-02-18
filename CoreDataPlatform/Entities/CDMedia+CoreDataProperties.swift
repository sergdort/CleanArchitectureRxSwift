//
//  CDMedia+CoreDataProperties.swift
//  NetworkAndSecurity
//
//  Created by sergdort on 07/01/2017.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDMedia {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMedia> {
        return NSFetchRequest<CDMedia>(entityName: "CDMedia");
    }

    @NSManaged public var type: String?
    @NSManaged public var url: String?
    @NSManaged public var uid: String?
    @NSManaged public var post: CDPost?

}
