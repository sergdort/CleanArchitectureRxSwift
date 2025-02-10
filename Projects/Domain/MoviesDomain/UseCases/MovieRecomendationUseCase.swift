import Dependencies
import XCTestDynamicOverlay
import SwiftUI

public protocol MovieRecomendationUseCase {
    func fetchSimilar(movieID: MovieID) async throws -> [Movie]
    func fetchRecomended(movieID: MovieID) async throws -> [Movie]
}

public enum MovieRecomendationUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: MovieRecomendationUseCase {
        func fetchSimilar(movieID: MovieID)  throws -> [Movie] {
            fatalError("Unimplemented")
        }
        func fetchRecomended(movieID: MovieID)  throws -> [Movie] {
            fatalError("Unimplemented")
        }
    }

    public static var testValue: MovieRecomendationUseCase {
        Unimplemented()
    }
}

public extension DependencyValues {
    var movieRecomendationUseCase: MovieRecomendationUseCase {
        get {
            self[MovieRecomendationUseCaseDependencyKey.self]
        }
        set {
            self[MovieRecomendationUseCaseDependencyKey.self] = newValue
        }
    }
}
