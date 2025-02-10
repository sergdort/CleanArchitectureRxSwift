import Foundation
import Dependencies
import XCTestDynamicOverlay

public protocol DiscoverAnimeUseCase {
    func fetch(
        page: Int,
        perPage: Int,
        filter: DiscoverAnimeFilter,
        mediaType: MediaType,
        genres: [String]?
    ) async throws -> Paged<[DiscoverMedia]>
}

public enum DiscoverAnimeUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: DiscoverAnimeUseCase {
        func fetch(
            page: Int,
            perPage: Int,
            filter: DiscoverAnimeFilter,
            mediaType: MediaType,
            genres: [String]?
        )  throws -> Paged<[DiscoverMedia]> {
            unimplemented(
                #function,
                placeholder: Paged<[DiscoverMedia]>(
                    response: [],
                    pageInfo: PageInfo(currentPage: 0, hasNextPage: false)
                )
            )
        }
    }

    public static var testValue: DiscoverAnimeUseCase {
        Unimplemented()
    }
}

extension DependencyValues {
    public var discoverAnimeUseCase: DiscoverAnimeUseCase {
        get {
            self[DiscoverAnimeUseCaseDependencyKey.self]
        }
        set {
            self[DiscoverAnimeUseCaseDependencyKey.self] = newValue
        }
    }
}
