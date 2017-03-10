//
//  CDTodo+Ext.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import CoreData
import Domain
import QueryKit
import RxSwift

extension CDTodo {
    static var title: Attribute<String> { return Attribute("title")}
    static var completed: Attribute<Bool> { return Attribute("completed")}
    static var userId: Attribute<Int> { return Attribute("userId")}
    static var uid: Attribute<Int> { return Attribute("uid")}
}

extension CDTodo: DomainConvertibleType {
    func asDomain() -> Todo {
        return Todo(completed: completed,
                    title: title!,
                    uid: Int(uid),
                    userId: Int(userId))
    }
}

extension CDTodo: Persistable {
    static var entityName: String {
        return "CDTodo"
    }
}

extension Todo: CoreDataRepresentable {
    typealias CoreDataType = CDTodo
    
    func update(entity: CDTodo) {
        entity.uid = Int64(uid)
        entity.completed = completed
        entity.title = title
        entity.userId = Int64(userId)
    }
}
