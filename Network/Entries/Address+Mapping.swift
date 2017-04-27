//
//  Address+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import ObjectMapper

extension Address: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        city = try map.value("city")
        geo = try map.value("geo")
        street = try map.value("street")
        suite = try map.value("suite")
        zipcode = try map.value("zipcode")
    }
}
