import AnimeAPI
import AnimeDomain
import Dependencies

extension DiscoverAnimeUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: DiscoverAnimeUseCase {
        AnimeAPIClient.shared
    }
}
