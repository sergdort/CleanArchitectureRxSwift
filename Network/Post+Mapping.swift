//
//  Post+Mapping.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import JASON

extension JSONKeys {
    static let id = JSONKey<Int>("id")
    static let userId = JSONKey<Int>("userId")

    static let title = JSONKey<JSON>("title")
    static let body = JSONKey<String>("body")
}

extension Post {

    init(_ json: JSON) {
    }
}
