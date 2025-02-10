import AnimeDomain
import AnimeAPI
import Dependencies

extension AnimeDetailUseCaseDependencyKey: @retroactive DependencyKey {
    public static var liveValue: AnimeDetailUseCase {
        AnimeAPIClient.shared
    }
}
