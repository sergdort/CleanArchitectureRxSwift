//
//  CDPost+CoreDataClass.swift
//  NetworkAndSecurity
//
//  Created by sergdort on 07/01/2017.
//  Copyright © 2017 sergdort. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import Domain
import QueryKit
import RxSwift

extension CDPost {
    static var title: Attribute<String> { return Attribute("title")}
    static var content: Attribute<String> { return Attribute("content")}
    static var createDate: Attribute<Date> { return Attribute("createDate")}
    static var updateDate: Attribute<Date> { return Attribute("updateDate")}
    static var media: Attribute<CDMedia> { return Attribute("media")}
    static var location: Attribute<CDLocation> { return Attribute("location")}
}

extension CDPost: DomainConvertibleType {
    func asDomain() -> Post {
        return Post(uid: uid!,
                    createDate: createDate! as Date,
                    updateDate: updateDate! as Date,
                    title: title!,
                    content: content!,
                    media: media?.asDomain(),
                    location: location?.asDomain())
    }
}

extension CDPost: Persistable {
    static var entityName: String {
        return "CDPost"
    }
    
    static func synced(post: CDPost, with media: CDMedia?, location: CDLocation?) -> CDPost {
        post.media = media
        post.location = location
        return post
    }
}

extension Post: CoreDataRepresentable {
    typealias CoreDataType = CDPost

    func sync(in context: NSManagedObjectContext) -> Observable<CDPost> {
        let syncSelf = context.rx.sync(entity: self, update: update)
        let syncMedia = media?.sync(in: context).map(Optional.init) ?? Observable.just(nil)
        let syncLocation = location?.sync(in: context).map(Optional.init) ?? Observable.just(nil)
        return Observable.zip(syncSelf, syncMedia, syncLocation, resultSelector: CDPost.synced)
    }
    
    func update(entity: CDPost) {
        entity.uid = uid
        entity.createDate = createDate as NSDate
        entity.updateDate = updateDate as NSDate
        entity.title = title
        entity.content = content
    }
}
