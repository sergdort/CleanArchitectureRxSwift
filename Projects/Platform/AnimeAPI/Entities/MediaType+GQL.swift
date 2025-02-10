import AnimeDomain

extension AnimeDomain.MediaType {
    var asGQL: AnimeAPI.MediaType {
        switch self {
        case .anime:
            return .anime
        case .manga:
            return .manga
        }
    }
}
