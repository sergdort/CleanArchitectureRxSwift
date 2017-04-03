//
//  CDPhoto+CoreDataProperties.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPhoto> {
        return NSFetchRequest<CDPhoto>(entityName: "CDPhoto");
    }

    @NSManaged public var albumId: String
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: String
    @NSManaged public var url: String?

}
