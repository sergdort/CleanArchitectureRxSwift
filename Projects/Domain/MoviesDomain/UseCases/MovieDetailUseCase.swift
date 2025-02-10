import Dependencies

public protocol MovieDetailUseCaseProtocol {
    func fetchDetail(for movieID: MovieID) async throws -> MovieDetail
}

public enum MovieDetailUseCaseProtocolDependencyKey: TestDependencyKey {
    struct Unimplemented: MovieDetailUseCaseProtocol {
        func fetchDetail(for movieID: MovieID)  throws -> MovieDetail {
            fatalError("Unimplemented")
        }
    }

    public static var testValue: MovieDetailUseCaseProtocol {
        Unimplemented()
    }
}

public extension DependencyValues {
    var movieDetailUseCase: MovieDetailUseCaseProtocol {
        get {
            self[MovieDetailUseCaseProtocolDependencyKey.self]
        }
        set {
            self[MovieDetailUseCaseProtocolDependencyKey.self] = newValue
        }
    }
}
