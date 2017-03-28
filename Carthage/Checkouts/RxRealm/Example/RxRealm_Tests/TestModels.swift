//
//  TestModels.swift
//  RxRealm
//
//  Created by Marin Todorov on 4/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import RealmSwift

//MARK: Message
class Message: Object {
    
    dynamic var text = ""
    
    var recipients = List<User>()
    let mentions = LinkingObjects(fromType: User.self, property: "lastMessage")
    
    convenience init(_ text: String) {
        self.init()
        self.text = text
    }
}

extension Array where Element: Message {
    func equalTo(_ to: [Message]) -> Bool {
        guard count == to.count else {return false}
        let (result, _) = reduce((true, 0)) {acc, el in
            guard acc.0 && self[acc.1] == to[acc.1] else {return (false, 0)}
            return (true, acc.1+1)
        }
        return result
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text
}

//MARK: User
class User: Object {
    dynamic var name = ""
    dynamic var lastMessage: Message?
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.name == rhs.name
}

//MARK: UniqueObject
class UniqueObject: Object {
    dynamic var id = 0
    dynamic var name = ""
    
    convenience init(_ id: Int) {
        self.init()
        self.id = id
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

func ==(lhs: UniqueObject, rhs: UniqueObject) -> Bool {
    return lhs.id == rhs.id
}
