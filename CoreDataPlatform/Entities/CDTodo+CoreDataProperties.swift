//
//  CDTodo+CoreDataProperties.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTodo> {
        return NSFetchRequest<CDTodo>(entityName: "CDTodo");
    }

    @NSManaged public var completed: Bool
    @NSManaged public var title: String?
    @NSManaged public var uid: String
    @NSManaged public var userId: String

}
