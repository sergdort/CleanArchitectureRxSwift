//
//  RMComment.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import QueryKit
import Domain
import RealmSwift
import Realm

final class RMComment: Object {

    dynamic var body: String = ""
    dynamic var email: String = ""
    dynamic var name: String = ""
    dynamic var postId: String = ""
    dynamic var uid: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMComment {
    static var body: Attribute<String> { return Attribute("body")}
    static var email: Attribute<String> { return Attribute("email")}
    static var name: Attribute<String> { return Attribute("name")}
    static var postId: Attribute<String> { return Attribute("postId")}
    static var uid: Attribute<String> { return Attribute("uid")}
}

extension RMComment: DomainConvertibleType {
    func asDomain() -> Comment {
        return Comment(body: body,
                       email: email,
                       name: name,
                       postId: postId,
                       uid: uid)
    }
}

extension Comment: RealmRepresentable {
    
    func asRealm() -> RMComment {
        return RMComment.build { object in
            object.body = body
            object.email = email
            object.name = name
            object.uid = uid
            object.postId = postId
        }
    }
}
