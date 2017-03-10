//
//  CDComment+CoreDataProperties.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDComment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDComment> {
        return NSFetchRequest<CDComment>(entityName: "CDComment");
    }

    @NSManaged public var body: String?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var postId: Int64
    @NSManaged public var uid: Int64

}
