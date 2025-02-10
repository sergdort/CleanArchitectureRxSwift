import MoviesDomain

public protocol MoviesListsCoordinator {
  func showDetail(for movie: Movie)
  func showCustomList(_ list: MovieList)
  func showCreatCustomList(didCreateList: @escaping () -> Void)
}
