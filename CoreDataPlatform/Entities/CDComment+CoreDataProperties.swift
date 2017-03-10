//
//  CDComment+CoreDataProperties.swift
//  
//
//  Created by Andrey Yastrebov on 10.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CDComment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDComment> {
        return NSFetchRequest<CDComment>(entityName: "CDComment");
    }

    @NSManaged public var uid: Int64
    @NSManaged public var postId: Int64
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var body: String?

}
