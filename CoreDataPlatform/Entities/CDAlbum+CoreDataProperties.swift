//
//  CDAlbum+CoreDataProperties.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData


extension CDAlbum {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAlbum> {
        return NSFetchRequest<CDAlbum>(entityName: "CDAlbum");
    }

    @NSManaged public var title: String?
    @NSManaged public var uid: String
    @NSManaged public var userId: String

}
