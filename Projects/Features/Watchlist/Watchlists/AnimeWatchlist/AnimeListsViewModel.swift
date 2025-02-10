import AnimeDomain
import Dependencies
import SwiftUI
import UI

@Observable
public final class AnimeListsViewModel {
    @ObservationIgnored
    @Dependency(\.mediaSeenlistUseCase)
    private var seenlistUseCase: MediaSeenlistUseCase
    
    @ObservationIgnored
    @Dependency(\.mediaWatchlistUseCase)
    private var watchlistUseCase: MediaWatchlistUseCase
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    var props = Props()
    
    public init() {}
    
    func fetch() {
        do {
            props.seenlist = try seenlistUseCase.getSeenList()
            props.watchlist = try watchlistUseCase.getWatchlist()
        } catch {
            errorToast.show()
        }
    }
    
    struct Props {
        var watchlist: MediaWatchlist?
        var seenlist: MediaSeenlist?
    }
}
