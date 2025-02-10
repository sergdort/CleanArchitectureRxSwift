import MoviesAPI
import MoviesDomain
import Dependencies

extension MovieCreditsUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: any MovieCreditsUseCase {
        @Dependency(\.httpClient) var httpClient
        return MovieCreditsGateway(client: httpClient)
    }
}
