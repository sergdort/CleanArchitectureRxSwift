//
//  Company+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import ObjectMapper

extension Company: ImmutableMappable {
    
    // JSON -> Object
    public init(map: Map) throws {
        bs = try map.value("bs")
        catchPhrase = try map.value("catchPhrase")
        name = try map.value("name")
    }
}
