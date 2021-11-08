import Foundation
import RxSwift

protocol AbstractCache {
    associatedtype T
    func save(object: T) -> Completable
    func save(objects: [T]) -> Completable
    func fetch(withID id: String) -> Maybe<T>
    func fetchObjects() -> Maybe<[T]>
}

final class Cache<T: Encodable>: AbstractCache where T == T.Encoder.DomainType {
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

    private let path: String
    private let cacheScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.CleanAchitecture.Network.Cache.queue")

    init(path: String) {
        self.path = path
    }

    func save(object: T) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.completed)
                    return Disposables.create()
                }
            let path = url.appendingPathComponent(self.path)
                .appendingPathComponent("\(object.uid)")
                .appendingPathComponent(FileNames.objectFileName)
                .absoluteString
            
            if NSKeyedArchiver.archiveRootObject(object.encoder, toFile: path) {
                observer(.completed)
            } else {
                observer(.error(Error.saveObject(object)))
            }
            
            return Disposables.create()
        }.subscribe(on: cacheScheduler)
    }

    func save(objects: [T]) -> Completable {
        return Completable.create { (observer) -> Disposable in
            guard let directoryURL = self.directoryURL() else {
                observer(.completed)
                return Disposables.create()
            }
            let path = directoryURL
                .appendingPathComponent(FileNames.objectsFileName)
            self.createDirectoryIfNeeded(at: directoryURL)
            do {
                try NSKeyedArchiver.archivedData(withRootObject: objects.map{ $0.encoder })
                    .write(to: path)
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }.subscribe(on: cacheScheduler)
    }

    func fetch(withID id: String) -> Maybe<T> {
        return Maybe<T>.create { (observer) -> Disposable in
            guard let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
                    observer(.completed)
                    return Disposables.create()
            }
            let path = url.appendingPathComponent(self.path)
                .appendingPathComponent("\(id)")
                .appendingPathComponent(FileNames.objectFileName)
                .absoluteString
            
            guard let object = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? T.Encoder else {
                observer(.completed)
                return Disposables.create()
            }
            observer(MaybeEvent<T>.success(object.asDomain()))
            return Disposables.create()
        }.subscribe(on: cacheScheduler)
    }

    func fetchObjects() -> Maybe<[T]> {
        return Maybe<[T]>.create { (observer) -> Disposable in
            guard let directoryURL = self.directoryURL() else {
                observer(.completed)
                return Disposables.create()
            }
            let fileURL = directoryURL
                .appendingPathComponent(FileNames.objectsFileName)
            guard let objects = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? [T.Encoder] else {
                observer(.completed)
                return Disposables.create()
            }
            observer(MaybeEvent.success(objects.map { $0.asDomain() }))
                return Disposables.create()
        }.subscribe(on: cacheScheduler)
    }
    
    private func directoryURL() -> URL? {
        return FileManager.default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
            .first?
            .appendingPathComponent(path)
    }
    
    private func createDirectoryIfNeeded(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print("Cache Error createDirectoryIfNeeded \(error)")
        }
    }
}
