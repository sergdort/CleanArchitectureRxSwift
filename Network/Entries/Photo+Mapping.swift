//
//  Photo+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import ObjectMapper

extension Photo: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        albumId = try map.value("albumId", using: UidTransform())
        thumbnailUrl = try map.value("thumbnailUrl")
        title = try map.value("title")
        uid = try map.value("id", using: UidTransform())
        url = try map.value("url")
    }
}
