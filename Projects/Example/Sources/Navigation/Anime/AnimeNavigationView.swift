import Anime
import AnimeDomain
import SwiftUI
import ComposableArchitecture

@MainActor
struct AnimeNavigationView: View {
    @Bindable
    private var coordinator: AnimeCoordinator
    private let store: StoreOf<AnimeListReducer>

    init(coordinator: AnimeCoordinator, store: StoreOf<AnimeListReducer>) {
        self.store = store
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.routes) {
            AnimeListView(store: store)
            .navigationDestination(for: AnimeCoordinator.Route.self) { route in
                switch route {
                case .animeDetail(let param):
                    AnimeDetailView(store: param.value)
                case .animeList(let param):
                    AnimeListView(store: param.value)
                }
            }
        }
    }
}

@MainActor
@Observable
final class AnimeCoordinator: Anime.AnimeCoordinator {
    var routes: [Route] = []

    func showDetails(for anime: DiscoverMedia) {
        let viewModel = AnimeDetailViewModel(anime: anime, coordinator: self)
        let store = Store(
            initialState: AnimeDetailReducer.State(anime: anime),
            reducer: {
                AnimeDetailReducer(coordinator: self)
            }
        )
        routes.append(.animeDetail(RouteIdentifier(value: store, id: { _ in anime.id })))
    }
    
    func showMedia(for genre: String) {
        let store = Store(
            initialState: AnimeListReducer.State(genre: genre),
            reducer: {
                AnimeListReducer(coordinator: self)
            }
        )
        routes.append(.animeList(.init(value: store, id: { _ in genre })))
    }

    enum Route: Hashable {
        case animeDetail(RouteIdentifier<StoreOf<AnimeDetailReducer>>)
        case animeList(RouteIdentifier<StoreOf<AnimeListReducer>>)
    }
}
