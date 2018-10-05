//
//  RMAlbum.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import QueryKit
import Domain
import RealmSwift
import Realm

final class RMAlbum: Object {

    @objc dynamic var title: String = ""
    @objc dynamic var uid: String = ""
    @objc dynamic var userId: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMAlbum {
    static var title: Attribute<String> { return Attribute("title")}
    static var userId: Attribute<String> { return Attribute("userId")}
    static var uid: Attribute<String> { return Attribute("uid")}
}

extension RMAlbum: DomainConvertibleType {
    func asDomain() -> Album {
        return Album(title: title, uid: uid, userId: userId)
    }
}

extension Album: RealmRepresentable {
    
    func asRealm() -> RMAlbum {
        return RMAlbum.build { object in
            object.title = title
            object.uid = uid
            object.userId = userId
        }
    }
}
