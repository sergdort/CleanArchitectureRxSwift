import AnimeDomain
import AnimeDB
import Dependencies

extension MediaWatchlistUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: any MediaWatchlistUseCase {
        SDMediaWatchlistRepository()
    }
}

extension MovieSeenlistUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: any MediaSeenlistUseCase {
        SDMediaSeenlistRepository()
    }
}
