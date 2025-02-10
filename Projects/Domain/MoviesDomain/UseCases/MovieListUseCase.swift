import Dependencies

public protocol MovieListUseCase {
    func getCustomLists() throws -> [MovieList]
    @discardableResult
    func add(movie: Movie, to list: MovieList) throws -> MovieList
    @discardableResult
    func remove(movie: Movie, from list: MovieList) throws -> MovieList
    @discardableResult
    func create(name: String, imagePath: String?) throws -> MovieList
    
    func isMovieInMovieList(_ movie: Movie) -> Bool
}

public enum MovieListUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: MovieListUseCase {
        func getCustomLists() throws -> [MovieList] {
            fatalError("Unimplemented")
        }

        func add(movie: Movie, to list: MovieList) throws -> MovieList {
            fatalError("Unimplemented")
        }

        func remove(movie: Movie, from list: MovieList) throws -> MovieList {
            fatalError("Unimplemented")
        }

        func create(name: String, imagePath: String?) throws -> MovieList {
            fatalError("Unimplemented")
        }
        
        func searchListCover(query: String) async throws -> [MovieImage] {
            fatalError("Unimplemented")
        }
        
        func isMovieInMovieList(_ movie: Movie) -> Bool {
            fatalError("Unimplemented")
        }
    }

    public static var testValue: MovieListUseCase {
        Unimplemented()
    }
}

@MainActor
public protocol MovieWatchlistUseCase {
    func contains(movie: Movie) -> Bool
    @discardableResult
    func add(movie: Movie) throws -> MovieWatchlist
    @discardableResult
    func remove(movie: Movie) throws -> MovieWatchlist
    func getWatchlist() throws -> MovieWatchlist
}

public enum MovieWatchlistUseCaseDependencyKey: TestDependencyKey {
    @MainActor
    struct Unimplemented: MovieWatchlistUseCase {
        func contains(movie: Movie) -> Bool {
            fatalError("Unimplemented")
        }

        func add(movie: Movie) throws -> MovieWatchlist {
            fatalError("Unimplemented")
        }

        func remove(movie: Movie) throws -> MovieWatchlist {
            fatalError("Unimplemented")
        }

        func getWatchlist() throws -> MovieWatchlist {
            fatalError("Unimplemented")
        }
    }

    @MainActor
    public static var testValue: MovieWatchlistUseCase {
        Unimplemented()
    }
}

public protocol MovieSeenlistUseCase {
    func contains(movie: Movie) -> Bool
    @discardableResult
    func add(movie: Movie) throws -> MovieSeenList
    @discardableResult
    func remove(movie: Movie) throws -> MovieSeenList
    func getSeenList() throws -> MovieSeenList
}

public enum MovieSeenlistUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: MovieSeenlistUseCase {
        func contains(movie: Movie) -> Bool {
            fatalError("Unimplemented")
        }

        func add(movie: Movie) throws -> MovieSeenList {
            fatalError("Unimplemented")
        }

        func remove(movie: Movie) throws -> MovieSeenList {
            fatalError("Unimplemented")
        }

        func getSeenList() throws -> MovieSeenList {
            fatalError("Unimplemented")
        }
    }

    public static var testValue: MovieSeenlistUseCase {
        Unimplemented()
    }
}

public extension DependencyValues {
    var movieListUseCase: MovieListUseCase {
        get {
            self[MovieListUseCaseDependencyKey.self]
        }
        set {
            self[MovieListUseCaseDependencyKey.self] = newValue
        }
    }

    var movieWatchlistUseCase: MovieWatchlistUseCase {
        get {
            self[MovieWatchlistUseCaseDependencyKey.self]
        }
        set {
            self[MovieWatchlistUseCaseDependencyKey.self] = newValue
        }
    }

    var movieSeenlistUseCase: MovieSeenlistUseCase {
        get {
            self[MovieSeenlistUseCaseDependencyKey.self]
        }
        set {
            self[MovieSeenlistUseCaseDependencyKey.self] = newValue
        }
    }
}

public enum MovieListError: Error {
    case listNotFound
}
