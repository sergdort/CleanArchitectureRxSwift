//
//  Comment+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import ObjectMapper

extension Comment: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        body = try map.value("body")
        email = try map.value("email")
        name = try map.value("name")
        postId = try map.value("postId", using: UidTransform())
        uid = try map.value("id", using: UidTransform())
    }
}
