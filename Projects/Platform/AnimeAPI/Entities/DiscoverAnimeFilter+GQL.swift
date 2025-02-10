import AnimeDomain

extension DiscoverAnimeFilter {
    var asMediaSort: [MediaSort] {
        switch self {
        case .allTimePopular:
            return [.popularityDesc]
        case .trending:
            return [.trendingDesc]
        case .topRated:
            return [.scoreDesc]
        }
    }
}
