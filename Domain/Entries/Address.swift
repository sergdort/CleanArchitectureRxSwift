//
//  Address.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation

public struct Address: Codable {

    public let city: String
    public let geo: Location
    public let street: String
    public let suite: String
    public let zipcode: String

    public init(city: String,
                geo: Location,
                street: String,
                suite: String,
                zipcode: String) {
        self.city = city
        self.geo = geo
        self.street = street
        self.suite = suite
        self.zipcode = zipcode
    }
}

extension Address: Equatable {
    public static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.city == rhs.city &&
            lhs.geo == rhs.geo &&
            lhs.street == rhs.street &&
            lhs.suite == rhs.suite &&
            lhs.zipcode == rhs.zipcode
    }
}
