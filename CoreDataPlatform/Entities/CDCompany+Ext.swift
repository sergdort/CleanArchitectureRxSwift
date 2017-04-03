//
//  CDCompany+Ext.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData
import Domain
import QueryKit
import RxSwift

extension CDCompany {
    static var bs: Attribute<String> { return Attribute("bs")}
    static var catchPhrase: Attribute<String> { return Attribute("catchPhrase")}
    static var name: Attribute<String> { return Attribute("name")}
}

extension CDCompany: DomainConvertibleType {
    func asDomain() -> Company {
        return Company(bs: bs!,
                       catchPhrase: catchPhrase!,
                       name: name!)
    }
}

extension CDCompany: Persistable {
    static var entityName: String {
        return "CDCompany"
    }
}

extension Company: CoreDataRepresentable {
    internal var uid: String {
        return ""
    }

    typealias CoreDataType = CDCompany
    
    func update(entity: CDCompany) {
        entity.bs = bs
        entity.name = name
        entity.catchPhrase = catchPhrase
    }
}
