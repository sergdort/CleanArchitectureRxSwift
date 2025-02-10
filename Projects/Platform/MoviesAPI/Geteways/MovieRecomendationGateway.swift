import MoviesDomain
import HTTPClient
import Foundation

public final class MovieRecomendationGateway: MovieRecomendationUseCase {
    private let client: DataFetching
    private let decoder = JSONDecoder()
    private let dateDormatter = DateFormatter()
    
    public init(client: DataFetching) {
        self.client = client
        dateDormatter.dateFormat = "YYYY-MM-DD"
        decoder.userInfo[.dateFormatter] = dateDormatter
    }
    
    public func fetchSimilar(movieID: MovieID) async throws -> [Movie] {
        let resource = Resource(path: "/movie/\(movieID.rawValue)/recommendations")
        let data = try await client.fetch(resource: resource)
        let result = try decoder.decode(PageResult<Movie>.self, from: data)
        return result.results
    }
    
    public func fetchRecomended(movieID: MovieID) async throws -> [Movie] {
        let resource = Resource(path: "/movie/\(movieID.rawValue)/similar")
        let data = try await client.fetch(resource: resource)
        let result = try decoder.decode(PageResult<Movie>.self, from: data)
        return result.results
    }
}
