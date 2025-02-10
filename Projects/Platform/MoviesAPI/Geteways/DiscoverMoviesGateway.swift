import Foundation
import HTTPClient
import MoviesDomain

public final class DiscoverMoviesGateway: MoviesDomain.DiscoverMoviesGateway {
    private let client: DataFetching
    private let decoder = JSONDecoder()
    private let dateDormatter = DateFormatter()

    public init(client: DataFetching) {
        self.client = client
        dateDormatter.dateFormat = "YYYY-MM-DD"
        decoder.userInfo[.dateFormatter] = dateDormatter
    }

    public func fetch(request: DiscoverMoviesRequest) async throws -> PageResult<Movie> {
        do {
            let data = try await client.fetch(resource: request.makeResource())
            let page = try decoder.decode(PageResult<Movie>.self, from: data)
            return page
        } catch let error as NetworkError {
            if case .notConnectedToInternet = error {
                throw OfflineError()
            }
            throw error
        } catch {
            throw error
        }
    }
}

extension DiscoverMoviesRequest {
    func makeResource() -> Resource {
        switch self {
        case .nowPlaying:
            return Resource(path: "/movie/now_playing", query: [:])
        case .popular:
            return Resource(path: "/movie/popular", query: [:])
        case .topRated:
            return Resource(path: "/movie/top_rated", query: [:])
        case .upcoming:
            return Resource(path: "/movie/upcoming", query: [:])
        }
    }
}
