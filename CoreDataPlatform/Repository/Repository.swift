import Foundation
import CoreData
import RxSwift

func abstractMethod() -> Never {
    fatalError("abstract method")
}

class AbstractRepository<T> {
    func query(with predicate: NSPredicate? = nil,
               sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[T]> {
        abstractMethod()
    }
    func save(entity: T) -> Observable<Void> {
        abstractMethod()
    }
}

final class Repository<T: CoreDataRepresentable>: AbstractRepository<T> where T == T.CoreDataType.DomainType {
    private let context: NSManagedObjectContext
    private let scheduler: ContextScheduler

    init(context: NSManagedObjectContext) {
        self.context = context
        self.scheduler = ContextScheduler(context: context)
    }

    override func query(with predicate: NSPredicate? = nil,
                        sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[T]> {
        let request = T.CoreDataType.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return context.rx.entities(fetchRequest: request)
            .mapToDomain()
            .subscribeOn(scheduler)
    }

    override func save(entity: T) -> Observable<Void> {
        return entity.sync(in: context)
            .mapToVoid()
            .flatMapLatest(context.rx.save)
            .subscribeOn(scheduler)
    }
}
