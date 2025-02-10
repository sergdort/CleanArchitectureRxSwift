import Dependencies
import XCTestDynamicOverlay

public protocol PersonDetailsUseCase {
    func fetchPersonDetails(with id: PersonID) async throws -> PersonDetails
}

public enum PersonDetailsUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: PersonDetailsUseCase {
        func fetchPersonDetails(with id: PersonID)  throws -> PersonDetails {
            fatalError()
        }
    }

    public static var testValue: PersonDetailsUseCase {
        Unimplemented()
    }
}

extension DependencyValues {
    public var personDetailsUseCase: PersonDetailsUseCase {
        get {
            self[PersonDetailsUseCaseDependencyKey.self]
        }
        set {
            self[PersonDetailsUseCaseDependencyKey.self] = newValue
        }
    }
}

#if DEBUG
public final class MockPersonDetailsUseCase: PersonDetailsUseCase {
    public var _fetchPersonDetails: (PersonID) -> PersonDetails = { _ in
        unimplemented("_fetchPersonDetails", placeholder: .example)
    }
    
    public init() {}
    
    public func fetchPersonDetails(with id: PersonID) async throws -> PersonDetails {
        _fetchPersonDetails(id)
    }
}
#endif
