import MoviesDomain
import MoviesAPI
import Dependencies

extension MovieSearchUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: any MovieSearchUseCase {
        @Dependency(\.httpClient) var httpClient
        
        return SearchMoviesGateway(client: httpClient)
    }
}
