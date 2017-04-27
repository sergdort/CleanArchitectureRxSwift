//
//  RMUser.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import QueryKit
import Domain
import RealmSwift
import Realm

final class RMUser: Object {

    dynamic var address: RMAddress?
    dynamic var company: RMCompany?
    dynamic var email: String = ""
    dynamic var name: String = ""
    dynamic var phone: String = ""
    dynamic var uid: String = ""
    dynamic var username: String = ""
    dynamic var website: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMUser {
    static var website: Attribute<String> { return Attribute("website")}
    static var email: Attribute<String> { return Attribute("email")}
    static var name: Attribute<String> { return Attribute("name")}
    static var phone: Attribute<String> { return Attribute("phone")}
    static var username: Attribute<String> { return Attribute("username")}
    static var uid: Attribute<String> { return Attribute("uid")}
    static var address: Attribute<RMAddress> { return Attribute("address")}
    static var company: Attribute<RMCompany> { return Attribute("company")}
}

extension RMUser: DomainConvertibleType {
    func asDomain() -> User {
        return User(address: address!.asDomain(),
                    company: company!.asDomain(),
                    email: email,
                    name: name,
                    phone: phone,
                    uid: uid,
                    username: username,
                    website: website)
    }
}

extension User: RealmRepresentable {
    func asRealm() -> RMUser {
        return RMUser.build { object in
            object.uid = uid
            object.address = address.asRealm()
            object.company = company.asRealm()
            object.email = email
            object.name = name
            object.phone = phone
            object.username = username
            object.website = website
        }
    }
}
