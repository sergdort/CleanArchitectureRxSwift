import Foundation

public protocol DiscoverMoviesGateway {
    func fetch(request: DiscoverMoviesRequest) async throws -> PageResult<Movie>
}

public enum DiscoverMoviesRequest: Hashable, CaseIterable {
    case nowPlaying
    case popular
    case topRated
    case upcoming
}
