import Foundation
import Dependencies
import XCTestDynamicOverlay

public protocol MovieCreditsUseCase {
    func fetchCast(movieID: MovieID) async throws -> MovieCast
}

public enum MovieCreditsUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: MovieCreditsUseCase {
        func fetchCast(movieID: MovieID)  throws -> MovieCast {
            fatalError("Unimplemented")
        }
    }

    public static var testValue: MovieCreditsUseCase {
        Unimplemented()
    }
}

public extension DependencyValues {
    var movieCreditsUseCase: MovieCreditsUseCase {
        get {
            self[MovieCreditsUseCaseDependencyKey.self]
        }
        set {
            self[MovieCreditsUseCaseDependencyKey.self] = newValue
        }
    }
}
