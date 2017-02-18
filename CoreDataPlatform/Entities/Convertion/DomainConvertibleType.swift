import Foundation
import CoreData
import RxSwift
import QueryKit

protocol DomainConvertibleType {
    associatedtype DomainType

    func asDomain() -> DomainType
}



protocol CoreDataRepresentable {
    associatedtype CoreDataType: Persistable
    
    var uid: String {get}
    
    func update(entity: CoreDataType)
}

extension CoreDataRepresentable {
    func sync(in context: NSManagedObjectContext) -> Observable<CoreDataType> {
        return context.rx.sync(entity: self, update: update)
    }
}
