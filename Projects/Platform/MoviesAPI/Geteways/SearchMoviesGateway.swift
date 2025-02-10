import Foundation
import HTTPClient
import MoviesDomain

public final class SearchMoviesGateway: MovieSearchUseCase {
    private let client: DataFetching
    private let decoder = JSONDecoder()
    private let dateDormatter = DateFormatter()

    public init(client: DataFetching) {
        self.client = client
        dateDormatter.dateFormat = "YYYY-MM-DD"
        decoder.userInfo[.dateFormatter] = dateDormatter
    }

    public func search(query: String, page: Int) async throws -> PageResult<Movie> {
        let resource = Resource(path: "/search/movie", query: ["query": query, "page": "\(page)"])
        let data = try await client.fetch(resource: resource)
        let page = try decoder.decode(PageResult<Movie>.self, from: data)
        
        return page
    }
}
