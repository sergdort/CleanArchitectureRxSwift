//
//  RMCompany.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import QueryKit
import Domain
import RealmSwift
import Realm

final class RMCompany: Object {

    dynamic var bs: String = ""
    dynamic var catchPhrase: String = ""
    dynamic var name: String = ""
}

extension RMCompany {
    static var bs: Attribute<String> { return Attribute("bs")}
    static var catchPhrase: Attribute<String> { return Attribute("catchPhrase")}
    static var name: Attribute<String> { return Attribute("name")}
}

extension RMCompany: DomainConvertibleType {
    func asDomain() -> Company {
        return Company(bs: bs,
                       catchPhrase: catchPhrase,
                       name: name)
    }
}

extension Company: RealmRepresentable {
    internal var uid: String {
        return ""
    }
    
    func asRealm() -> RMCompany {
        return RMCompany.build { object in
            object.bs = bs
            object.catchPhrase = catchPhrase
            object.name = name
        }
    }
}
