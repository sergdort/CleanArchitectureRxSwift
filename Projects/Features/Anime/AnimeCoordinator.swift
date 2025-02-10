import AnimeDomain

@MainActor
public protocol AnimeCoordinator {
    func showDetails(for anime: DiscoverMedia)
    func showMedia(for genre: String)
}
