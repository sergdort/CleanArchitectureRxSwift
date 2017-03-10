//
//  CDAddress+CoreDataProperties.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAddress> {
        return NSFetchRequest<CDAddress>(entityName: "CDAddress");
    }

    @NSManaged public var city: String?
    @NSManaged public var street: String?
    @NSManaged public var suite: String?
    @NSManaged public var zipcode: String?
    @NSManaged public var geo: CDLocation?
    @NSManaged public var user: CDUser?

}
