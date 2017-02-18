import Foundation
import CoreData
import QueryKit
import Domain
import RxSwift


extension CDMedia {
    static var type: Attribute<String> { return Attribute("type")}
    static var url: Attribute<String> { return Attribute("url")}
    static var post: Attribute<CDPost> { return Attribute("post")}
}

extension CDMedia: DomainConvertibleType {
    func asDomain() -> Media {
        return Media(uid: uid!, type: MediaType(rawValue: type!)!, url: URL(string: url!)!)
    }
}

extension CDMedia: Persistable {
    static var entityName: String {
        return "CDMedia"
    }
}

extension Media: CoreDataRepresentable {
    typealias CoreDataType = CDMedia
    
    func update(entity: CDMedia) {
        entity.uid = uid
        entity.url = url.absoluteString
        entity.type = type.rawValue
    }
}
