import Dependencies
import MoviesAPI
import MoviesDomain

extension MovieDetailUseCaseProtocolDependencyKey: @retroactive DependencyKey {
    public static var liveValue: MovieDetailUseCaseProtocol {
        @Dependency(\.httpClient) var httpClient
        return MoviesAPI.MovieDetailsGateway(client: httpClient)
    }
}
