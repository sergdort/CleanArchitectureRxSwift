import Foundation
import Dependencies
import XCTestDynamicOverlay

public protocol AnimeDetailUseCase {
    func fetchBy(id: Int) async throws -> MediaDetail
}

public enum AnimeDetailUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: AnimeDetailUseCase {
        func fetchBy(id: Int)  throws -> MediaDetail {
            fatalError()
        }
    }

    public static var testValue: AnimeDetailUseCase {
        Unimplemented()
    }
}

extension DependencyValues {
    public var animeDetailUseCase: AnimeDetailUseCase {
        get {
            self[AnimeDetailUseCaseDependencyKey.self]
        }
        set {
            self[AnimeDetailUseCaseDependencyKey.self] = newValue
        }
    }
}
