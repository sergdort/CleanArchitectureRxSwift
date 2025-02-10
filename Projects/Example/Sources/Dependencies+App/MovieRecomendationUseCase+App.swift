import Dependencies
import MoviesAPI
import MoviesDomain

extension MovieRecomendationUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: MovieRecomendationUseCase {
        @Dependency(\.httpClient) var httpClient
        return MovieRecomendationGateway(client: httpClient)
    }
}
