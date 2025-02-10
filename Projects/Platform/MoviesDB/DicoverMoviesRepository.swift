import FileCache
import Foundation
import MoviesDomain
import SwiftData
import Dependencies
import SwiftDataHelpers

public final class DicoverMoviesRepository: MoviesDomain.DicoverMoviesRepository {
    private let fileCache = FileCache(name: "DicoverMoviesRepository")
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init() {}

    public func movies(
        for reuqest: MoviesDomain.DiscoverMoviesRequest
    ) throws -> [Movie] {
        let data = try fileCache.loadFile(path: reuqest.repoPath)
        let movies = try decoder.decode([Movie].self, from: data)
        return movies
    }

    public func save(movies: [Movie], for request: DiscoverMoviesRequest) throws {
        try fileCache.persist(item: movies, encoder: encoder, path: request.repoPath)
    }
}

public final class SDDicoverMoviesRepository: MoviesDomain.DicoverMoviesRepository {
    @Dependency(\.moviesStore)
    private var store: Store
    
    public init() {}
    
    public func movies(for reuqest: MoviesDomain.DiscoverMoviesRequest) throws -> [MoviesDomain.Movie] {
        let movies = try store.fetchAll(of: SDMovie.self, sortBy: [])
        
        return movies.map(\.toDomain)
    }
    
    public func save(movies: [Movie], for request: DiscoverMoviesRequest) throws {
        let movieIDs = movies.map(\.id.rawValue)
        let discriptor = FetchDescriptor<SDMovie>(
            predicate: #Predicate<SDMovie> { item in
                movieIDs.contains(item.movieId)
            }
        )
        let alreadyStoredMovies = Set(try store.fetch(discriptor).map(\.movieId))
        for movie in movies {
            if alreadyStoredMovies.contains(movie.id.rawValue) == false {
                store.insert(movie.toSDMovie)
            }
        }
        try store.save()
    }
}

private extension DiscoverMoviesRequest {
    var repoPath: String {
        switch self {
        case .nowPlaying:
            return "nowPlaying"
        case .popular:
            return "popular"
        case .topRated:
            return "topRated"
        case .upcoming:
            return "upcoming"
        }
    }
}
