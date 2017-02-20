import QueryKit
import Domain
import RealmSwift
import Realm

final class RMPost: Object {
    dynamic var uid: String = ""
    dynamic var createDate: NSDate = NSDate()
    dynamic var updateDate: NSDate = NSDate()
    dynamic var title: String = ""
    dynamic var content: String = ""
    dynamic var media: RMMedia? = nil
    dynamic var location: RMLocation? = nil

    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMPost: DomainConvertibleType {
    func asDomain() -> Post {
        return Post(uid: uid,
                createDate: createDate as Date,
                updateDate: updateDate as Date,
                title: title,
                content: content,
                media: media?.asDomain(),
                location: location?.asDomain())
    }
}

extension Post: RealmRepresentable {
    func asRealm() -> RMPost {
        return RMPost.build { object in
            object.uid = uid
            object.createDate = createDate as NSDate
            object.updateDate = updateDate as NSDate
            object.content = content
            object.media = media?.asRealm()
            object.location = location?.asRealm()
        }
    }
}
