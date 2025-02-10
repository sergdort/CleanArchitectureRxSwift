import MoviesDomain
import Dependencies
import MoviesAPI
import MoviesDB
import HTTPClient
import Foundation


extension DiscoverMoviesUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: any DiscoverMoviesUseCaseProtocol {
        @Dependency(\.httpClient) var httpClient
        
        return DiscoverMoviesUseCase(
            gateway: MoviesAPI.DiscoverMoviesGateway(client: httpClient),
            repository: MoviesDB.DicoverMoviesRepository()
        )
    }
}
