//
//  CDComment+CoreDataProperties.swift
//  
//
//  Created by Andrey Yastrebov on 04.04.17.
//
//

import Foundation
import CoreData


extension CDComment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDComment> {
        return NSFetchRequest<CDComment>(entityName: "CDComment")
    }

    @NSManaged public var body: String?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var postId: String?
    @NSManaged public var uid: String?

}
