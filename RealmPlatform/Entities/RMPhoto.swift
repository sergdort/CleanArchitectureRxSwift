//
//  RMPhoto.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import QueryKit
import Domain
import RealmSwift
import Realm

final class RMPhoto: Object {
    @objc dynamic var albumId: String = ""
    @objc dynamic var thumbnailUrl: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var uid: String = ""
    @objc dynamic var url: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMPhoto {
    static var title: Attribute<String> { return Attribute("title")}
    static var thumbnailUrl: Attribute<String> { return Attribute("thumbnailUrl")}
    static var url: Attribute<String> { return Attribute("url")}
    static var albumId: Attribute<String> { return Attribute("albumId")}
    static var uid: Attribute<String> { return Attribute("uid")}
}

extension RMPhoto: DomainConvertibleType {
    func asDomain() -> Photo {
        return Photo(albumId: albumId,
                     thumbnailUrl: thumbnailUrl,
                     title: title,
                     uid: uid,
                     url: url)
    }
}

extension Photo: RealmRepresentable {
    
    func asRealm() -> RMPhoto {
        return RMPhoto.build { object in
            object.albumId = albumId
            object.thumbnailUrl = thumbnailUrl
            object.title = title
            object.uid = uid
            object.url = url
        }
    }
}
