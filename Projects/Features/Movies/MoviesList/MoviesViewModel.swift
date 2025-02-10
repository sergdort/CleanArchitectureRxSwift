import Dependencies
import MoviesDomain
import SwiftUI
import UI

@MainActor
@Observable public final class MoviesViewModel {
    var movies: [Movie] = []
    
    @ObservationIgnored
    @Dependency(\.discoverMoviesUseCase)
    private var useCase: DiscoverMoviesUseCaseProtocol
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    @ObservationIgnored
    private let coordinator: MoviesCoordinator

    var request: DiscoverMoviesRequest
    
    public init(coordinator: MoviesCoordinator) {
        self.request = .nowPlaying
        self.coordinator = coordinator
    }
    
    func fetch() async {
        do {
            let page = try await useCase.fetch(request: request, page: 1)
            movies = page.results
        } catch {
            errorToast.show()
        }
    }
    
    func filter(request: DiscoverMoviesRequest) {
        self.request = request
        Task {
            await fetch()
        }
    }
    
    func didSelect(movie: Movie) {
        coordinator.showDetail(for: movie)
    }
}
