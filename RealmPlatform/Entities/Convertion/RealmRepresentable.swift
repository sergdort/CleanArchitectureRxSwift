import Foundation

protocol RealmRepresentable {
    associatedtype RealmType: DomainConvertibleType

    var uid: String { get }

    func asRealm() -> RealmType
}
