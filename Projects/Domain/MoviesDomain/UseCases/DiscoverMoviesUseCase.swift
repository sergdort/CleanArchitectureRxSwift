import Foundation
import Dependencies
import XCTestDynamicOverlay

public protocol DiscoverMoviesUseCaseProtocol {
    func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie>
}

public final class DiscoverMoviesUseCase: DiscoverMoviesUseCaseProtocol {
    private let gateway: DiscoverMoviesGateway
    private let repository: DicoverMoviesRepository
    
    public init(gateway: DiscoverMoviesGateway, repository: DicoverMoviesRepository) {
        self.gateway = gateway
        self.repository = repository
    }
    
    public func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie> {
        do {
            let pageResult = try await gateway.fetch(request: request)
            if page == 1 {
                try? await repository.save(movies: pageResult.results, for: request)
            }
            return pageResult
        } catch {
            if error is OfflineError {
                let movies = try await repository.movies(for: request)
                return PageResult(page: page, results: movies, totalPages: 0, totalResults: movies.count)
            }
            throw error
        }
    }
}

public enum DiscoverMoviesUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: DiscoverMoviesUseCaseProtocol {
        func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie> {
            unimplemented(#function, placeholder: .init(page: 0, results: [], totalPages: 0, totalResults: 0))
        }
    }
    
    public static var testValue: DiscoverMoviesUseCaseProtocol {
        Unimplemented()
    }
}

extension DependencyValues {
    public var discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol {
        get {
            self[DiscoverMoviesUseCaseDependencyKey.self]
        }
        set {
            self[DiscoverMoviesUseCaseDependencyKey.self] = newValue
        }
    }
}
