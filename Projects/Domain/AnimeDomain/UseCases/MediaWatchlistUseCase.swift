import Dependencies
import XCTestDynamicOverlay

public protocol MediaWatchlistUseCase {
    func contains(media: DiscoverMedia) -> Bool
    @discardableResult
    func add(media: DiscoverMedia) throws -> MediaWatchlist
    @discardableResult
    func remove(media: DiscoverMedia) throws -> MediaWatchlist
    func getWatchlist() throws -> MediaWatchlist
}

public enum MediaWatchlistUseCaseDependencyKey: TestDependencyKey {
    public static var testValue: MediaWatchlistUseCase {
        struct Unimplemented: MediaWatchlistUseCase {
            func contains(media: DiscoverMedia) -> Bool {
                unimplemented(#function, placeholder: false)
            }
            
            func add(media: DiscoverMedia) throws -> MediaWatchlist {
                unimplemented(#function, placeholder: MediaWatchlist(media: []))
            }
            
            func remove(media: DiscoverMedia) throws -> MediaWatchlist {
                unimplemented(#function, placeholder: MediaWatchlist(media: []))
            }
            
            func getWatchlist() throws -> MediaWatchlist {
                unimplemented(#function, placeholder: MediaWatchlist(media: []))
            }
        }
        
        return Unimplemented()
    }
}

extension DependencyValues {
    public var mediaWatchlistUseCase: MediaWatchlistUseCase {
        get {
            self[MediaWatchlistUseCaseDependencyKey.self]
        }
        set {
            self[MediaWatchlistUseCaseDependencyKey.self] = newValue
        }
    }
}
