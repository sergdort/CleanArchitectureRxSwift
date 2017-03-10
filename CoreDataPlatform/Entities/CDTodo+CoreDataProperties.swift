//
//  CDTodo+CoreDataProperties.swift
//  
//
//  Created by Andrey Yastrebov on 10.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CDTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTodo> {
        return NSFetchRequest<CDTodo>(entityName: "CDTodo");
    }

    @NSManaged public var userId: Int64
    @NSManaged public var uid: Int64
    @NSManaged public var title: Int64
    @NSManaged public var completed: Bool

}
