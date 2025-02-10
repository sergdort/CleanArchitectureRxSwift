import Dependencies
import MoviesAPI
import MoviesDomain

extension PersonDetailsUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: PersonDetailsUseCase {
        @Dependency(\.httpClient) var httpClient
        return PersonDetailsGateway(client: httpClient)
    }
}
