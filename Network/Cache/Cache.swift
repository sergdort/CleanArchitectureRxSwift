import Foundation
import RxSwift

func abstractMethod() -> Never {
    fatalError("abstract method")
}

class AbstractChache<T> {
    func save(object: T) -> Completable {
        abstractMethod()
    }
    func save(objects: [T]) -> Completable {
        abstractMethod()
    }

    func fetchObject() -> Maybe<T> {
        abstractMethod()
    }

    func fetchObjects() -> Maybe<[T]> {
        abstractMethod()
    }
}

final class Cache<T: Encodable>: AbstractChache<T> where T == T.Encoder.DomainType {
    enum Error: Swift.Error {
        case saveObject(T)
        case saveObjects([T])
        case fetchObject(T.Type)
        case fetchObjects(T.Type)
    }
    enum FileNames {
        static var objectFileName: String {
            return "\(T.self).dat"
        }
        static var objectsFileName: String {
            return "\(T.self)s.dat"
        }
    }

    private let objectPath: String
    private let objectsPath: String
    private let chacheScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.CleanAchitecture.Network.Cache.queue")

    init(objectPath: String, objectsPath: String) {
        self.objectPath = objectsPath
        self.objectsPath = objectsPath
    }

    override func save(object: T) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.error(Error.saveObject(object)))
                    return Disposables.create()
                }
            let path = url.appendingPathComponent(self.objectPath)
                .appendingPathComponent(FileNames.objectFileName)
                .absoluteString
            
            if NSKeyedArchiver.archiveRootObject(object.encoder, toFile: path) {
                observer(.completed)
            } else {
                observer(.error(Error.saveObject(object)))
            }
            
            return Disposables.create()
        }.subscribeOn(chacheScheduler)
    }

    override func save(objects: [T]) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.error(Error.saveObjects(objects)))
                    return Disposables.create()
            }
            let path = url.appendingPathComponent(self.objectsPath)
                .appendingPathComponent(FileNames.objectsFileName)
                .absoluteString
            
            if NSKeyedArchiver.archiveRootObject(objects.map{ $0.encoder } , toFile: path) {
                observer(.completed)
            } else {
                observer(.error(Error.saveObjects(objects)))
            }
            
            return Disposables.create()
        }.subscribeOn(chacheScheduler)
    }

    override func fetchObject() -> Maybe<T> {
        return Maybe<T>.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.completed)
                    return Disposables.create()
            }
            let path = url.appendingPathComponent(self.objectPath)
                .appendingPathComponent(FileNames.objectFileName)
                .absoluteString
            
            guard let object = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? T.Encoder else {
                observer(.completed)
                return Disposables.create()
            }
            observer(MaybeEvent<T>.success(object.asDomain()))
            return Disposables.create()
        }.subscribeOn(chacheScheduler)
    }

    override func fetchObjects() -> Maybe<[T]> {
        return Maybe<[T]>.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.completed)
                    return Disposables.create()
            }
            let path = url.appendingPathComponent(self.objectPath)
                .appendingPathComponent(FileNames.objectFileName)
                .absoluteString
            
            guard let objects = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [T.Encoder] else {
                observer(.completed)
                return Disposables.create()
            }
            observer(MaybeEvent.success(objects.map { $0.asDomain() }))
            return Disposables.create()
        }.subscribeOn(chacheScheduler)
    }
}
