import FileCache
import Foundation
import MoviesDomain
import Dependencies
import SwiftData
import SwiftDataHelpers

public final class MovieSeenlistRepository: MovieSeenlistUseCase {
  private let fileCache = FileCache(name: "MovieSeenlistRepository")
  private let watchlistPath = "watchlist.json"
  private let seenListPath = "seenlist.json"
  private let customListsPath = "custom_list.json"
  private let moviesDateFormatter = DateFormatter()
  private let dateFormatter = DateFormatter()
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  
  public init () {
    moviesDateFormatter.dateFormat = "YYYY-MM-DD"
    decoder.userInfo[.dateFormatter] = dateFormatter
    encoder.userInfo[.dateFormatter] = dateFormatter
  }

  @discardableResult
  public func add(movie: Movie) throws -> MovieSeenList {
    var seenList = try getSeenList()
      if seenList.movies.contains(where: { movie.id == $0.id } ) {
      return seenList
    }
    seenList.movies.append(movie)
    try fileCache.persist(data: encoder.encode(seenList), path: seenListPath)
    return seenList
  }
  
  @discardableResult
  public func remove(movie: Movie) throws -> MovieSeenList {
    var seenList = try getSeenList()
    seenList.movies.removeAll(where: { $0.id == movie.id })
    try fileCache.persist(data: encoder.encode(seenList), path: seenListPath)
    return seenList
  }

  public func getSeenList() throws -> MovieSeenList {
    if fileCache.exists(atPath: seenListPath) == false {
      let movieSeenList = MovieSeenList(movies: [])
      try fileCache.persist(data: encoder.encode(movieSeenList), path: seenListPath)
      return movieSeenList
    }
    let data = try fileCache.loadFile(path: seenListPath)
    let movieSeenList = try decoder.decode(MovieSeenList.self, from: data)
    return movieSeenList
  }
  
  public func contains(movie: Movie) -> Bool {
    let seenList = (try? getSeenList()) ?? MovieSeenList(movies: [])
    return seenList.movies.contains(where: { $0.id == movie.id })
  }
}

public final class SDMovieSeenlistRepository: MovieSeenlistUseCase {
    @Dependency(\.moviesStore)
    private var store: Store
    private var seenlist: SDMovieSeenList?
    
    public init() {}
    
    public func contains(movie: Movie) -> Bool {
        let seenlist = try? getSDSeenlist()
        return seenlist?.movies.contains(where: { $0.movieId == movie.id.rawValue }) ?? false
    }
    
    public func add(movie: Movie) throws -> MovieSeenList {
        let seenlist = try getSDSeenlist()
        let fetch = FetchDescriptor<SDMovie>(predicate: #Predicate { $0.movieId == movie.id.rawValue })
        if let sdMovie = try store.fetch(fetch).first {
            seenlist.movies.append(sdMovie)
        } else {
            let sdMovie = movie.toSDMovie
            seenlist.movies.append(sdMovie)
        }
        try store.save()
        return seenlist.toDomain
    }
    
    public func remove(movie: Movie) throws -> MovieSeenList {
        let seenlist = try getSDSeenlist()
        seenlist.movies.removeAll(where: { $0.movieId == movie.id.rawValue })
        try store.save()
        return seenlist.toDomain
    }
    
    public func getSeenList() throws -> MovieSeenList {
        try getSDSeenlist().toDomain
    }
    
    func getSDSeenlist() throws  -> SDMovieSeenList {
        if let seenlist = self.seenlist {
            return seenlist
        }
        if let seenlist = try store.fetchAll(of: SDMovieSeenList.self, sortBy: []).first {
            return seenlist
        }
        let seenlist = SDMovieSeenList(movies: [])
        self.seenlist = seenlist
        store.insert(seenlist)
        try store.save()
        return seenlist
    }
}
