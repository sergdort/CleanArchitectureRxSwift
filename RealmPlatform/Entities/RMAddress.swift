//
//  RMAddress.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import QueryKit
import Domain
import RealmSwift
import Realm

final class RMAddress: Object {

    @objc dynamic var city: String = ""
    @objc dynamic var geo: RMLocation?
    @objc dynamic var street: String = ""
    @objc dynamic var suite: String = ""
    @objc dynamic var zipcode: String = ""
}

extension RMAddress {
    static var city: Attribute<String> { return Attribute("city")}
    static var street: Attribute<String> { return Attribute("street")}
    static var suite: Attribute<String> { return Attribute("suite")}
    static var zipcode: Attribute<String> { return Attribute("zipcode")}
    static var geo: Attribute<RMLocation> { return Attribute("geo")}
}

extension RMAddress: DomainConvertibleType {
    func asDomain() -> Address {
        return Address(city: city,
                       geo: geo!.asDomain(),
                       street: street,
                       suite: suite,
                       zipcode: zipcode)
    }
}

extension Address: RealmRepresentable {
    internal var uid: String {
        return ""
    }
    
    func asRealm() -> RMAddress {
        return RMAddress.build { object in
            object.city = city
            object.geo = geo.asRealm()
            object.street = street
            object.suite = suite
            object.zipcode = zipcode
        }
    }
}
