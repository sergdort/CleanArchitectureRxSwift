import Foundation
import Apollo
import AnimeDomain
import ApolloExtensions

public final class AnimeAPIClient {
    private let client = ApolloClient(url: URL(string: "https://graphql.anilist.co")!)
    
    init() {
    }
    
    public static let shared = AnimeAPIClient()
}

extension AnimeAPIClient: DiscoverAnimeUseCase {
    public func fetch(
        page: Int,
        perPage: Int,
        filter: AnimeDomain.DiscoverAnimeFilter,
        mediaType: AnimeDomain.MediaType,
        genres: [String]?
    ) async throws -> AnimeDomain.Paged<[AnimeDomain.DiscoverMedia]> {
        let query = PaginatedMediaQuery(
            page: .some(page),
            perPage: .some(page),
            mediaSort: .some(filter.asMediaSort.map(GraphQLEnum.case)),
            type: .some(.case(mediaType.asGQL)),
            genreIn: genres.map { GraphQLNullable.some($0.map(Optional.some)) } ?? .null
        )
        let result = try await client.fetch(query: query)
        guard let page = result.page.flatMap(AnimeDomain.Paged.init(page:)) else {
            throw NoDataError()
        }
        return page
    }
}

extension AnimeAPIClient: AnimeDetailUseCase {
    public func fetchBy(id: Int) async throws -> MediaDetail {
        let query = MediaByIdQuery(mediaId: .some(id))
        let result = try await client.fetch(query: query)
        
        guard let media = result.media.map(MediaDetail.make(with:)) else {
            throw NoDataError()
        }
        
        return media
    }
}
