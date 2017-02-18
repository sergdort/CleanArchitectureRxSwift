import Foundation
import CoreData
import Domain
import QueryKit

extension CDLocation {
    static var latitude: Attribute<Double> { return Attribute("latitude")}
    static var longitude: Attribute<Double> { return Attribute("longitude")}
    static var name: Attribute<String> { return Attribute("name")}
    static var post: Attribute<CDPost> { return Attribute("post")}
}

extension CDLocation: DomainConvertibleType {
    func asDomain() -> Location {
        return Location(uid: uid!, latitude: latitude,
        longitude: longitude,
        name: name ?? "")
    }
}

extension CDLocation: Persistable {
    static var entityName: String {
        return "CDLocation"
    }
}

extension Location: CoreDataRepresentable {
    typealias CoreDataType = CDLocation
    
    func update(entity: CDLocation) {
        entity.uid = uid
        entity.latitude = latitude
        entity.longitude = longitude
    }
}
