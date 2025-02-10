import Apollo
import AnimeDomain
import Foundation

extension Paged where T == [DiscoverMedia] {
    init?(page: PaginatedMediaQuery.Data.Page) {
        guard let pageInfo = page.pageInfo, let media = page.media else {
            return nil
        }
        self.init(
            response: media.compactMap { $0 }.map {
                DiscoverMedia(media: $0.fragments.gQLDiscoverMedia)
            },
            pageInfo: PageInfo(gqlPageInfo: pageInfo)
        )
    }
}
