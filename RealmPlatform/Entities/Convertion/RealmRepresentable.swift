import Foundation

protocol RealmRepresentable {
    associatedtype RealmType: DomainConvertibleType

    var uid: Int {get}

    func asRealm() -> RealmType
}
