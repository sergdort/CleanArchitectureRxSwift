//
//  Album+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import ObjectMapper

extension Album: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        title = try map.value("title")
        uid = try map.value("id", using: UidTransform())
        userId = try map.value("userId", using: UidTransform())
    }
}
