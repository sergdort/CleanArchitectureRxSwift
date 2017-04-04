//
//  CDComment+Ext.swift
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

extension CDComment {
    static var body: Attribute<String> { return Attribute("body")}
    static var email: Attribute<String> { return Attribute("email")}
    static var name: Attribute<String> { return Attribute("name")}
    static var postId: Attribute<String> { return Attribute("postId")}
    static var uid: Attribute<String> { return Attribute("uid")}
}

extension CDComment: DomainConvertibleType {
    func asDomain() -> Comment {
        return Comment(body: body!,
                       email: email!,
                       name: name!,
                       postId: postId!,
                       uid: uid!)
    }
}

extension CDComment: Persistable {
    static var entityName: String {
        return "CDComment"
    }
}

extension Comment: CoreDataRepresentable {
    typealias CoreDataType = CDComment
    
    func update(entity: CDComment) {
        entity.uid = uid
        entity.name = name
        entity.body = body
        entity.email = email
        entity.postId = postId
    }
}
