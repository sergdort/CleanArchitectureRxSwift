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
    dynamic var albumId: Int = 0
    dynamic var thumbnailUrl: String = ""
    dynamic var title: String = ""
    dynamic var uid: Int = 0
    dynamic var url: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMPhoto {
    static var title: Attribute<String> { return Attribute("title")}
    static var thumbnailUrl: Attribute<String> { return Attribute("thumbnailUrl")}
    static var url: Attribute<String> { return Attribute("url")}
    static var albumId: Attribute<Int> { return Attribute("albumId")}
    static var uid: Attribute<Int> { return Attribute("uid")}
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
