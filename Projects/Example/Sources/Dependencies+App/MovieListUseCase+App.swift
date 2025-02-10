import Dependencies
import MoviesDB
import MoviesDomain

extension MovieListUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: MovieListUseCase {
        MovieListRepository()
    }
}

extension MovieWatchlistUseCaseDependencyKey: @retroactive DependencyKey {
    @MainActor
    public static var liveValue: MovieWatchlistUseCase {
        SDMovieWatchlistRepository() // MovieWatchlistRepository()
    }
}

extension MovieSeenlistUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: MovieSeenlistUseCase {
        SDMovieSeenlistRepository() //MovieSeenlistRepository()
    }
}
