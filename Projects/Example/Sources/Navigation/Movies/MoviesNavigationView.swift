import Combine
import Watchlist
import Movies
import MoviesDomain
import SwiftUI

@MainActor
struct MoviesNavigationView: View {
    @Bindable
    private var coordinator: MoviesCoordinator
    private let viewModel: MoviesViewModel
    
    init(coordinator: MoviesCoordinator, viewModel: MoviesViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.routes) {
            MoviesListView(viewModel: viewModel)
                .navigationTitle("Movies")
                .navigationDestination(for: MoviesCoordinator.Route.self) { route in
                    switch route {
                    case .movieDetail(let route):
                        MovieDetailView(viewModel: route.value)
                    case .personDetail(let route):
                        PersonDetailsView(viewModel: route.value)
                    case .addMoiveToList(let route):
                        AddToCustomListView(viewModel: route.value)
                    }
                }
        }
    }
}

@MainActor
@Observable
final class MoviesCoordinator: Movies.MoviesCoordinator {
    var routes: [Route] = []
        
    init() {
        self.routes = routes
    }
    
    func showDetail(for movie: Movie) {
        routes.append(.movieDetail(RouteIdentifier(value: MovieDetailViewModel(movie: movie, coordinator: self), id: \.movie.id)))
    }
    
    func showDetail(for person: Person) {
        let route = RouteIdentifier(
            value: PersonDetailsViewViewModel(person: person),
            id: \.person.id
        )
        routes.append(.personDetail(route))
    }
    
    func showAddMovieToCustomList(for movie: Movie) {
        let route = RouteIdentifier(
            value: AddToCustomListViewModel(movie: movie),
            id: \.movie.id
        )
        routes.append(.addMoiveToList(route))
    }
    
    enum Route: Hashable {
        case movieDetail(RouteIdentifier<MovieDetailViewModel>)
        case personDetail(RouteIdentifier<PersonDetailsViewViewModel>)
        case addMoiveToList(RouteIdentifier<AddToCustomListViewModel>)
    }
}

struct RouteIdentifier<T>: Hashable {
    let value: T
    let id: AnyHashable
    
    init<ID: Hashable>(value: T, id: (T) -> ID) {
        self.value = value
        self.id = AnyHashable(id(value))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RouteIdentifier<T>, rhs: RouteIdentifier<T>) -> Bool {
        return lhs.id == rhs.id
    }
}
