
//
//  User+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import ObjectMapper

extension User: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        address = try map.value("address")
        company = try map.value("company")
        email = try map.value("email")
        name = try map.value("name")
        phone = try map.value("phone")
        uid = try map.value("id", using: UidTransform())
        username = try map.value("username")
        website = try map.value("website")
    }
}
