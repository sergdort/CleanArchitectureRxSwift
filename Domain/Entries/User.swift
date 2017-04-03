//
//  User.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation

public struct User {

    public let address: Address
    public let company: Company
    public let email: String
    public let name: String
    public let phone: String
    public let uid: String
    public let username: String
    public let website: String

    public init(address: Address,
                company: Company,
                email: String,
                name: String,
                phone: String,
                uid: String,
                username: String,
                website: String) {
        self.address = address
        self.company = company
        self.email = email
        self.name = name
        self.phone = phone
        self.uid = uid
        self.username = username
        self.website = website
    }
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.address == rhs.address &&
            lhs.company == rhs.company &&
            lhs.email == rhs.email &&
            lhs.name == rhs.name &&
            lhs.phone == rhs.phone &&
            lhs.username == rhs.username &&
            lhs.website == rhs.website
    }
}
