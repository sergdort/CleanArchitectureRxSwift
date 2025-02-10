import Apollo
import AnimeDomain

extension PageInfo {
    init(gqlPageInfo: PaginatedMediaQuery.Data.Page.PageInfo) {
        self.init(currentPage: gqlPageInfo.currentPage ?? 0, hasNextPage: gqlPageInfo.hasNextPage ?? false)
    }
}
