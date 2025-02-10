import AnimeDomain
import ComposableArchitecture
import Dependencies
import UI

@Reducer
public struct AnimeDetailReducer {
    @Dependency(\.animeDetailUseCase)
    private var animeDetailUseCase: AnimeDetailUseCase
    
    @Dependency(\.mediaWatchlistUseCase)
    private var mediaWatchlistUseCase: MediaWatchlistUseCase
    
    @Dependency(\.mediaSeenlistUseCase)
    private var mediaSeenlistUseCase: MediaSeenlistUseCase
    
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    private let coordinator: AnimeCoordinator
    
    public init(coordinator: AnimeCoordinator) {
        self.coordinator = coordinator
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.getDetail, action: \.getDetail) {
            Fetch { animeId in
                try await animeDetailUseCase.fetchBy(id: animeId)
            }
            .errorHandling()
        }
        Reduce { state, action in
            switch action {
            case .viewDidLoad:
                state.isInWatchlist = mediaWatchlistUseCase.contains(media: state.anime)
                state.isInSeenlist = mediaSeenlistUseCase.contains(media: state.anime)
                return .send(.getDetail(.fetch(state.anime.id)))
            case .addToWatchlist:
                if state.isInWatchlist {
                    do {
                        try mediaWatchlistUseCase.remove(media: state.anime)
                        state.isInWatchlist = false
                    } catch {
                        errorToast.show()
                    }
                } else {
                    do {
                        try mediaWatchlistUseCase.add(media: state.anime)
                        state.isInWatchlist = true
                    } catch {
                        errorToast.show()
                    }
                }
                return .none
            case .addToSeenlist:
                if state.isInSeenlist {
                    do {
                        try mediaSeenlistUseCase.remove(media: state.anime)
                        state.isInSeenlist = false
                    } catch {
                        errorToast.show()
                    }
                } else {
                    do {
                        try mediaSeenlistUseCase.add(media: state.anime)
                        state.isInSeenlist = true
                    } catch {
                        errorToast.show()
                    }
                }
                return .none
            case .didTapGenre(let genere):
                return .run { @MainActor _ in
                    coordinator.showMedia(for: genere)
                }
            case .didTapMedia(let media):
                return .run { @MainActor _ in
                    coordinator.showDetails(for: media)
                }
            default:
                return .none
            }
        }
    }
    
    @ObservableState
    public struct State: Equatable {
        var getDetail: Fetch<MediaDetail, Int>.State = .notInitiated
        var isInWatchlist = false
        var isInSeenlist = false
        let anime: DiscoverMedia
        
        public init(anime: DiscoverMedia) {
            self.anime = anime
        }
        
        var mediaDetail: MediaDetail? {
            getDetail.fetched
        }
        
        var isLoading: Bool {
            getDetail.isFetching
        }
    }
    
    public enum Action: Equatable {
        case getDetail(Fetch<MediaDetail, Int>.Action)
        case viewDidLoad
        case addToWatchlist
        case addToSeenlist
        case didTapGenre(String)
        case didTapMedia(DiscoverMedia)
    }
}
