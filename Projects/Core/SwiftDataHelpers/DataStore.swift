import Foundation
import SwiftData
import Dependencies

public protocol Store {
    func fetchAll<T: PersistentModel>(of type: T.Type, sortBy: [SortDescriptor<T>]) throws -> [T]
    
    func fetch<T: PersistentModel>(_ discriptor: FetchDescriptor<T>) throws -> [T]
    
    func fetchFirst<T: PersistentModel>(_ discriptor: FetchDescriptor<T>) throws -> T?
    
    func insert<T: PersistentModel>(_ model: T)
    
    func save() throws
}
