import Domain
import RealmSwift
import Realm

final class RMPost: Object {
    @objc dynamic var uid: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var createdAt: String = ""

    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMPost: DomainConvertibleType {
    func asDomain() -> Post {
        return Post(body: body,
                    title: title,
                    uid: uid,
                    userId: userId,
                    createdAt: createdAt)
    }
}

extension Post: RealmRepresentable {
    func asRealm() -> RMPost {
        return RMPost.build { object in
            object.uid = uid
            object.userId = userId
            object.title = title
            object.body = body
            object.createdAt = createdAt
        }
    }
}
