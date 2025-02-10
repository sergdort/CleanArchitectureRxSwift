import Anime
import ComposableArchitecture
import Movies
import SwiftUI
import Watchlist

@MainActor
final class AppCoordinator: ObservableObject {
    @Published
    var tab: Tab = .movies

    private lazy var moviesCoordinator = MoviesCoordinator()
    private lazy var animeCoordinator = AnimeCoordinator()
    private lazy var watchlistsCoordinator = WatchlistsCoordinator()
    private lazy var moviesViewModel = MoviesViewModel(coordinator: moviesCoordinator)
    private lazy var moviesListsViewModel = MoviesListsViewModel(coordinator: watchlistsCoordinator)
    private lazy var animeListsViewModel = AnimeListsViewModel()
    private lazy var animeListStore = Store(
        initialState: AnimeListReducer.State(genre: nil),
        reducer: {
            AnimeListReducer(coordinator: animeCoordinator)
        }
    )

    func makeMoviesView() -> some View {
        MoviesNavigationView(coordinator: moviesCoordinator, viewModel: moviesViewModel)
            .tabItem {
                tabbarItem(text: "Movies", image: "film.stack")
            }
    }

    func makeAnimeView() -> some View {
        AnimeNavigationView(coordinator: animeCoordinator, store: animeListStore)
            .tabItem {
                tabbarItem(text: "Anime", image: "sparkles.rectangle.stack")
            }
    }

    func makeWatchlistsView() -> some View {
        WatchlistNavigationView(
            coordinator: watchlistsCoordinator,
            moviesViewModel: moviesListsViewModel,
            animeViewModel: animeListsViewModel
        )
        .tabItem {
            tabbarItem(text: "My Lists", image: "heart.square.fill")
        }
    }

    private func tabbarItem(text: String, image: String) -> some View {
        VStack {
            Image(systemName: image)
                .imageScale(.large)
            Text(text)
        }
    }
}

extension AppCoordinator {
    enum Tab {
        case movies
        case anime
        case watchlist
    }
}
