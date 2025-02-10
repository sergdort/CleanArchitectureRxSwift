import Dependencies
import XCTestDynamicOverlay

public protocol MediaSeenlistUseCase {
    func contains(media: DiscoverMedia) -> Bool
    @discardableResult
    func add(media: DiscoverMedia) throws -> MediaSeenlist
    @discardableResult
    func remove(media: DiscoverMedia) throws -> MediaSeenlist
    func getSeenList() throws -> MediaSeenlist
}

public enum MovieSeenlistUseCaseDependencyKey: TestDependencyKey {
    public static var testValue: MediaSeenlistUseCase {
        struct Unimplemented: MediaSeenlistUseCase {
            func contains(media: DiscoverMedia) -> Bool {
                unimplemented(#function, placeholder: false)
            }
            
            func add(media: DiscoverMedia) throws -> MediaSeenlist {
                unimplemented(#function, placeholder: MediaSeenlist(media: []))
            }
            
            func remove(media: DiscoverMedia) throws -> MediaSeenlist {
                unimplemented(#function, placeholder: MediaSeenlist(media: []))
            }
            
            func getSeenList() throws -> MediaSeenlist {
                unimplemented(#function, placeholder: MediaSeenlist(media: []))
            }
        }
        
        return Unimplemented()
    }
}

extension DependencyValues {
    public var mediaSeenlistUseCase: MediaSeenlistUseCase {
        get {
            self[MovieSeenlistUseCaseDependencyKey.self]
        }
        set {
            self[MovieSeenlistUseCaseDependencyKey.self] = newValue
        }
    }
}
