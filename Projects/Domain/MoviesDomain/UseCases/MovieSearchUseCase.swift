import Dependencies
import XCTestDynamicOverlay

public protocol MovieSearchUseCase {
    func search(query: String, page: Int) async throws -> PageResult<Movie>
}

public enum MovieSearchUseCaseDependencyKey: TestDependencyKey {
    public static var testValue: any MovieSearchUseCase {
        struct Unimplemented: MovieSearchUseCase {
            func search(query: String, page: Int) async throws -> PageResult<Movie> {
                unimplemented(
                    #function,
                    placeholder: PageResult(
                        page: 0,
                        results: [],
                        totalPages: 0,
                        totalResults: 0
                    )
                )
            }
        }
        
        return Unimplemented()
    }
}

extension DependencyValues {
    public var movieSearchUseCase: any MovieSearchUseCase {
        get {
            self[MovieSearchUseCaseDependencyKey.self]
        }
        set {
            self[MovieSearchUseCaseDependencyKey.self] = newValue
        }
    }
}
