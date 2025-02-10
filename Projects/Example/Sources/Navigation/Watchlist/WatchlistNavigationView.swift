import Movies
import MoviesDomain
import SwiftUI
import SwiftUINavigation
import Watchlist

struct WatchlistNavigationView: View {
    @Bindable var coordinator: WatchlistsCoordinator
    let moviesViewModel: MoviesListsViewModel
    let animeViewModel: AnimeListsViewModel
  
    public init(
        coordinator: WatchlistsCoordinator,
        moviesViewModel: MoviesListsViewModel,
        animeViewModel: AnimeListsViewModel
    ) {
        self.coordinator = coordinator
        self.moviesViewModel = moviesViewModel
        self.animeViewModel = animeViewModel
    }
  
    var body: some View {
        NavigationStack(path: $coordinator.routes) {
            MediaListsView(moviesViewModel: moviesViewModel, animeViewModel: animeViewModel)
                .navigationDestination(for: WatchlistsCoordinator.Route.self) { route in
                    switch route {
                    case .movieDetail(let route):
                        MovieDetailView(viewModel: route.value)
                    case .personDetail(let route):
                        PersonDetailsView(viewModel: route.value)
                    case .customList(let route):
                        CustomListView(movieList: route.value)
                    case .addToCustomList(let route):
                        AddToCustomListView(viewModel: route.value)
                    }
                }
                .sheet(item: $coordinator.modal) { modal in
                    switch modal {
                    case .createCustomList(let didCreateList):
                        NavigationView {
                            CreateCustomListView(
                                viewModel: CreateCustomListViewModel(
                                    coordinator: coordinator,
                                    didCreateList: didCreateList
                                )
                            )
                        }
                    }
                }
        }
    }
}

@Observable
final class WatchlistsCoordinator: Watchlist.MoviesListsCoordinator, Movies.MoviesCoordinator, Watchlist.CreateCustomListCoordinator {
    var routes: [Route] = []
  
    var modal: Modal?
    
    enum Route: Hashable {
        case movieDetail(RouteIdentifier<MovieDetailViewModel>)
        case personDetail(RouteIdentifier<PersonDetailsViewViewModel>)
        case customList(RouteIdentifier<MovieList>)
        case addToCustomList(RouteIdentifier<AddToCustomListViewModel>)
    }
  
    enum Modal: Identifiable {
        case createCustomList(() -> Void)
    
        var id: String {
            switch self {
            case .createCustomList:
                return "createCustomList"
            }
        }
    }
  
    func showDetail(for movie: Movie) {
        let viewModel = MovieDetailViewModel(movie: movie, coordinator: self)
        routes.append(.movieDetail(.init(value: viewModel, id: \.movie.id)))
    }
    
    func showAddMovieToCustomList(for movie: Movie) {
        let viewModel = AddToCustomListViewModel(movie: movie)
        routes.append(.addToCustomList(.init(value: viewModel, id: \.movie.id)))
    }
  
    func showDetail(for person: Person) {
        let viewModel = PersonDetailsViewViewModel(person: person)
        routes.append(.personDetail(.init(value: viewModel, id: \.person.id)))
    }
  
    func showCustomList(_ customList: MovieList) {
        routes.append(.customList(.init(value: customList, id: \.id)))
    }
    
    func showCreatCustomList(didCreateList: @escaping () -> Void) {
        modal = .createCustomList(didCreateList)
    }
  
    func dismissCreateList() {
        modal = nil
    }
}
