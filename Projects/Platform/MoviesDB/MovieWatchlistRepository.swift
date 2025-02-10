import Dependencies
import FileCache
import Foundation
import MoviesDomain
import SwiftData
import SwiftDataHelpers

@MainActor
public final class MovieWatchlistRepository: MovieWatchlistUseCase {
    private let fileCache = FileCache(name: "MovieWatchlistRepository")
    private let watchlistPath = "watchlist.json"
    private let moviesDateFormatter = DateFormatter()
    private let dateFormatter = DateFormatter()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init() {
        moviesDateFormatter.dateFormat = "YYYY-MM-DD"
        decoder.userInfo[.dateFormatter] = dateFormatter
        encoder.userInfo[.dateFormatter] = dateFormatter
    }
  
    @discardableResult
    public func add(movie: Movie) throws -> MovieWatchlist {
        var watchlist = try getWatchlist()
        if watchlist.movies.contains(movie) {
            return watchlist
        }
        watchlist.movies.append(movie)
        try fileCache.persist(data: encoder.encode(watchlist), path: watchlistPath)
        return watchlist
    }
  
    @discardableResult
    public func remove(movie: Movie) throws -> MovieWatchlist {
        var watchlist = try getWatchlist()
        watchlist.movies.removeAll(where: { $0.id == movie.id })
        try fileCache.persist(data: encoder.encode(watchlist), path: watchlistPath)
        return watchlist
    }
  
    public func getWatchlist() throws -> MovieWatchlist {
        if fileCache.exists(atPath: watchlistPath) == false {
            let movieWatchlist = MovieWatchlist(movies: [])
            try fileCache.persist(data: encoder.encode(movieWatchlist), path: watchlistPath)
            return movieWatchlist
        }
        let data = try fileCache.loadFile(path: watchlistPath)
        let movieWatchlist = try decoder.decode(MovieWatchlist.self, from: data)
        return movieWatchlist
    }
  
    public func contains(movie: Movie) -> Bool {
        let watchlist = (try? getWatchlist()) ?? MovieWatchlist(movies: [])
        return watchlist.movies.contains(where: { $0.id == movie.id })
    }
}

@MainActor
public final class SDMovieWatchlistRepository: MovieWatchlistUseCase {
    @Dependency(\.moviesStore)
    private var store: Store
    private var watchlist: SDMovieWatchlist?
    
    public init() {}
    
    public func contains(movie: Movie) -> Bool {
        let watchlist = try? getSDWatchlist()
        return watchlist?.movies.contains(where: { $0.movieId == movie.id.rawValue }) ?? false
    }
    
    public func add(movie: Movie) throws -> MovieWatchlist {
        let watchlist = try getSDWatchlist()
        if watchlist.movies.contains(where: { movie.id.rawValue == $0.movieId }) {
            return watchlist.toDomain
        }
        let fetch = FetchDescriptor<SDMovie>(predicate: #Predicate { $0.movieId == movie.id.rawValue })
        if let sdMovie = try store.fetch(fetch).first {
            watchlist.movies.append(sdMovie)
        } else {
            let sdMovie = movie.toSDMovie
            watchlist.movies.append(sdMovie)
        }
        try store.save()
        return watchlist.toDomain
    }
    
    public func remove(movie: Movie) throws -> MovieWatchlist {
        let watchlist = try getSDWatchlist()
        watchlist.movies.removeAll(where: { $0.movieId == movie.id.rawValue })
        try store.save()
        return watchlist.toDomain
    }
    
    public func getWatchlist() throws -> MovieWatchlist {
        try getSDWatchlist().toDomain
    }
    
    func getSDWatchlist() throws -> SDMovieWatchlist {
        if let watchlist = self.watchlist {
            return watchlist
        }
        if let watchlist = try store.fetchAll(of: SDMovieWatchlist.self, sortBy: []).first {
            return watchlist
        }
        let watchlist = SDMovieWatchlist(movies: [])
        self.watchlist = watchlist
        store.insert(watchlist)
        try store.save()
        return watchlist
    }
}
