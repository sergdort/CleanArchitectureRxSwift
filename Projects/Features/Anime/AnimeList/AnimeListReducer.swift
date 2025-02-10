import AnimeDomain
import ComposableArchitecture
import Foundation
import UI

@Reducer
public struct AnimeListReducer {
    @Dependency(\.discoverAnimeUseCase)
    private var useCase: DiscoverAnimeUseCase
    
    private let coordinator: AnimeCoordinator
    
    public init(coordinator: AnimeCoordinator) {
        self.coordinator = coordinator
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.getMedia, action: \.getMedia) {
            Fetch { params in
                try await useCase.fetch(
                    page: 0,
                    perPage: 50,
                    filter: params.filter,
                    mediaType: params.mediaType,
                    genres: params.genre.map { [$0] } ?? nil
                )
            }
            .errorHandling()
        }
        Reduce { state, action in
            switch action {
            case .loadData:
                let params = Params(filter: state.filter, mediaType: state.mediaType, genre: state.genre)
                return .send(.getMedia(.fetch(params)))
            case .getMedia(.response(let response)):
                state.media = response.response
                return .none
            case .setFilter(let filter):
                state.filter = filter
                return .send(.loadData)
            case .setMediaType(let mediaType):
                state.mediaType = mediaType
                return .send(.loadData)
            case .didSelectMedia(let media):
                return .run { @MainActor _ in
                    coordinator.showDetails(for: media)
                }
            default:
                return .none
            }
        }
    }
    
    public struct Params: Equatable {
        var filter: DiscoverAnimeFilter
        var mediaType: MediaType
        var genre: String?
    }
    
    @ObservableState
    public struct State: Equatable {
        let genre: String?
        var filter: DiscoverAnimeFilter = .trending
        var mediaType: MediaType = .anime
        var media: [DiscoverMedia] = []
        var getMedia: Fetch<Paged<[DiscoverMedia]>, Params>.State = .notInitiated
        
        public init(genre: String?) {
            self.genre = genre
        }
    }
    
    public enum Action: Equatable {
        case setFilter(DiscoverAnimeFilter)
        case setMediaType(MediaType)
        case didSelectMedia(DiscoverMedia)
        case loadData
        case getMedia(Fetch<Paged<[DiscoverMedia]>, Params>.Action)
    }
}
