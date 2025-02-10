import Foundation
import SwiftData
import Dependencies
import SwiftDataHelpers

enum MoviesDataStack {
    static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                SDMovie.self,
                SDMovieWatchlist.self,
                SDMovieSeenList.self,
                SDMovieList.self
            ])
            return try ModelContainer(
                for: schema,
                configurations: ModelConfiguration("Movies")
            )
        } catch {
            fatalError("Could not create model container: \(error)")
        }
    }()
}

extension MoviesDataStack: DependencyKey {
    static let liveValue: Store = ContextStore(modelContainer: MoviesDataStack.modelContainer)
}

extension DependencyValues {
    var moviesStore: Store {
        get {
            self[MoviesDataStack.self]
        }
        set {
            self[MoviesDataStack.self] = newValue
        }
    }
}
