import Foundation
import SwiftData
import Dependencies
import SwiftDataHelpers

enum MediaDataStack {
    static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                SDDiscoverMedia.self,
                SDMediaWatchlist.self,
                SDMediaSeenlist.self,
                SDMediaList.self
            ])
            return try ModelContainer(
                for: schema,
                configurations: ModelConfiguration("Anime")
            )
        } catch {
            fatalError("Could not create model container: \(error)")
        }
    }()
}

extension MediaDataStack: DependencyKey {
    static let liveValue: Store = ContextStore(modelContainer: MediaDataStack.modelContainer)
}

extension DependencyValues {
    var animeStore: Store {
        get {
            self[MediaDataStack.self]
        }
        set {
            self[MediaDataStack.self] = newValue
        }
    }
}

