//
//  CDPhoto+CoreDataProperties.swift
//  
//
//  Created by Andrey Yastrebov on 04.04.17.
//
//

import Foundation
import CoreData


extension CDPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPhoto> {
        return NSFetchRequest<CDPhoto>(entityName: "CDPhoto")
    }

    @NSManaged public var albumId: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var url: String?

}
