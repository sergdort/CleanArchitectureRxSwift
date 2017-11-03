//
//  Location+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import ObjectMapper

extension Location: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        longitude = try map.value("longitude")
        latitude = try map.value("latitude")
    }
}
