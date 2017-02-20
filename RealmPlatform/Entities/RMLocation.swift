import Foundation
import QueryKit
import Domain
import RealmSwift
import Realm

final class RMLocation: Object {
    dynamic  var latitude: Double = 0
    dynamic  var longitude: Double = 0
    dynamic  var uid: String = ""
    dynamic  var name: String = ""

    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RMLocation {
    static var latitude: Attribute<Double> { return Attribute("latitude")}
    static var longitude: Attribute<Double> { return Attribute("longitude")}
}


extension RMLocation: DomainConvertibleType {
    func asDomain() -> Location {
        return Location(uid: uid,
                latitude: latitude,
                longitude: longitude,
                name: name)
    }
}

extension Location: RealmRepresentable {
    func asRealm() -> RMLocation {
        return RMLocation.build { object in
            object.uid = uid
            object.latitude = latitude
            object.longitude = longitude
            object.name = name
        }
    }
}
