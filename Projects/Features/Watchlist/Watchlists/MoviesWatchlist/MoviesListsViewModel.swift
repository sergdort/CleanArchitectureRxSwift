import Dependencies
import MoviesDomain
import SwiftUI
import UI

@Observable
public final class MoviesListsViewModel {
    @ObservationIgnored
    @Dependency(\.movieListUseCase)
    private var movieListUseCase: MovieListUseCase
  
    @ObservationIgnored
    @Dependency(\.movieWatchlistUseCase)
    private var movieWatchlistUseCase: MovieWatchlistUseCase
 
    @ObservationIgnored
    @Dependency(\.movieSeenlistUseCase)
    private var movieSeenlistUseCase: MovieSeenlistUseCase
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
  
    @ObservationIgnored
    private let coordinator: MoviesListsCoordinator
  
    var props = Props()
  
    public init(coordinator: MoviesListsCoordinator) {
        self.coordinator = coordinator
    }
  
    @MainActor
    func fetch() {
        do {
            props.customLists = try movieListUseCase.getCustomLists()
            props.watchlist = try movieWatchlistUseCase.getWatchlist()
            props.seenList = try movieSeenlistUseCase.getSeenList()
        } catch {
            errorToast.show()
        }
    }
  
    func didTap(movie: Movie) {
        coordinator.showDetail(for: movie)
    }
  
    @MainActor
    func didTapCreateCustomList() {
        coordinator.showCreatCustomList { [weak self] in
            self?.fetch()
        }
    }
  
    func didTap(customList: MovieList) {
        coordinator.showCustomList(customList)
    }
  
    struct Props {
        var watchlist: MovieWatchlist?
        var seenList: MovieSeenList?
        var customLists: [MovieList] = []
    }
}
