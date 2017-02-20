import Foundation
import QueryKit
import Domain
import RealmSwift
import Realm

final class RMMedia: Object {
    dynamic var uid: String = ""
    dynamic var type: String = ""
    dynamic var url: String = ""

    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMMedia: DomainConvertibleType {
    func asDomain() -> Media {
        return Media(uid: uid, type: MediaType(rawValue: type)!, url: URL(string: url)!)
    }
}

extension Media: RealmRepresentable {
    func asRealm() -> RMMedia {
        return RMMedia.build { object in
            object.uid = uid
            object.type = type.rawValue
            object.url = url.absoluteString
        }
    }
}
