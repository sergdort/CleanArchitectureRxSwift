import SwiftData
import Foundation

public final class ContextStore: Store {
    private let modelContext: ModelContext
        
    public init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
    }
    
    public func fetchAll<T>(of type: T.Type, sortBy: [SortDescriptor<T>]) throws -> [T] where T : PersistentModel {
        let fetch = FetchDescriptor(sortBy: sortBy)
        return try modelContext.fetch(fetch)
    }
    
    public func fetchFirst<T: PersistentModel>(_ discriptor: FetchDescriptor<T>) throws -> T? {
        return try modelContext.fetch(discriptor).first
    }
    
    public func fetch<T>(_ discriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel {
        return try modelContext.fetch(discriptor)
    }
    
    public func insert<T>(_ model: T) where T : PersistentModel {
        modelContext.insert(model)
    }
    
    public func save() throws {
        try modelContext.save()
    }
}
