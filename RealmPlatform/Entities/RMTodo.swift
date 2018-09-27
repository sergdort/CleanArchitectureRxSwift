//
//  RMTodo.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import QueryKit
import Domain
import RealmSwift
import Realm

final class RMTodo: Object {

    @objc dynamic var completed: Bool = false
    @objc dynamic var title: String = ""
    @objc dynamic var uid: String = ""
    @objc dynamic var userId: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMTodo {
    static var title: Attribute<String> { return Attribute("title")}
    static var completed: Attribute<Bool> { return Attribute("completed")}
    static var userId: Attribute<String> { return Attribute("userId")}
    static var uid: Attribute<String> { return Attribute("uid")}
}

extension RMTodo: DomainConvertibleType {
    func asDomain() -> Todo {
        return Todo(completed: completed,
                    title: title,
                    uid: uid,
                    userId: userId)
    }
}

extension Todo: RealmRepresentable {
    func asRealm() -> RMTodo {
        return RMTodo.build { object in
            object.uid = uid
            object.userId = userId
            object.title = title
            object.completed = completed
        }
    }
}
