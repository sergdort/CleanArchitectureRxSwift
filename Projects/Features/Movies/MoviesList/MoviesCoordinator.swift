import MoviesDomain

@MainActor
public protocol MoviesCoordinator {
    func showDetail(for movie: Movie)
    func showDetail(for person: Person)
    func showAddMovieToCustomList(for movie: Movie)
}
