import Dependencies
import FileCache
import Foundation
import MoviesDomain
import SwiftData
import SwiftDataHelpers

public final class MovieListRepository: MovieListUseCase {
    private let fileCache = FileCache(name: "MovieListRepository")
    private let customListsPath = "custom_lists.json"
    private let moviesDateFormatter = DateFormatter()
    private let dateFormatter = DateFormatter()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init() {
        moviesDateFormatter.dateFormat = "YYYY-MM-DD"
        decoder.userInfo[.dateFormatter] = dateFormatter
        encoder.userInfo[.dateFormatter] = dateFormatter
    }
  
    public func getCustomLists() throws -> [MovieList] {
        if fileCache.exists(atPath: customListsPath) == false {
            let emptyList: [MovieList] = []
            try fileCache.persist(data: encoder.encode(emptyList), path: customListsPath)
            return emptyList
        }
        let data = try fileCache.loadFile(path: customListsPath)
        let customLists = try decoder.decode([MovieList].self, from: data)
        return customLists
    }
  
    public func add(movie: Movie, to list: MovieList) throws -> MovieList {
        var customLists = try getCustomLists()
        guard let index = customLists.firstIndex(where: { $0.id == list.id }) else {
            throw MovieListError.listNotFound
        }
        customLists[index].movies.append(movie)
        try save(lists: customLists)
        return customLists[index]
    }
  
    public func remove(movie: Movie, from list: MovieList) throws -> MovieList {
        var customLists = try getCustomLists()
        guard let index = customLists.firstIndex(where: { $0.id == list.id }) else {
            throw MovieListError.listNotFound
        }
        customLists[index].movies.removeAll(where: { $0.id == movie.id })
        try save(lists: customLists)
        return customLists[index]
    }
  
    @discardableResult
    public func create(name: String, imagePath: String?) throws -> MovieList {
        let newList = MovieList(name: name, imagePath: imagePath, movies: [])
        guard fileCache.exists(atPath: customListsPath) else {
            try save(lists: [newList])
            return newList
        }
        let data = try fileCache.loadFile(path: customListsPath)
        var customLists = try decoder.decode([MovieList].self, from: data)
        customLists.append(newList)
    
        try save(lists: customLists)
    
        return newList
    }
    
    public func isMovieInMovieList(_ movie: Movie) -> Bool {
        let lists = (try? getCustomLists()) ?? []
        
        for list in lists {
            if list.movies.contains(where: { $0.id == movie.id }) {
                return true
            }
        }
        return false
    }
  
    private func save(lists: [MovieList]) throws {
        let data = try encoder.encode(lists)
        try fileCache.persist(data: data, path: customListsPath)
    }
}

public final class SDMovieListRepository: MovieListUseCase {
    @Dependency(\.moviesStore)
    private var store: Store
    
    public init() {}
    
    public func getCustomLists() throws -> [MovieList] {
        try store.fetchAll(of: SDMovieList.self, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            .map(\.toDomain)
    }
    
    public func add(movie: Movie, to list: MovieList) throws -> MovieList {
        guard let sdList = try store.fetchFirst(.init(predicate: SDMovieList.by(listID: list.id.uuidString))) else {
            throw Error.listNotFound
        }
        let sdMovie = try store.fetchFirst(.init(predicate: SDMovie.by(movieId: movie.id.rawValue))) ?? movie.toSDMovie
        sdList.movies.append(sdMovie)
        try store.save()
        return sdList.toDomain
    }
    
    public func remove(movie: MoviesDomain.Movie, from list: MovieList) throws -> MovieList {
        return list
    }
    
    public func create(name: String, imagePath: String?) throws -> MovieList {
        let id = UUID()
        let sdList = SDMovieList(listID: id.uuidString, name: name, imagePath: imagePath, movies: [])
        store.insert(sdList)
        try store.save()
        return MovieList(id: id, name: name, imagePath: imagePath, movies: [])
    }
    
    public func isMovieInMovieList(_ movie: Movie) -> Bool {
        guard let sdMovie = try? store.fetchFirst(.init(predicate: SDMovie.by(movieId: movie.id.rawValue))) else {
            return false
        }
        
        return sdMovie.lists.isEmpty
    }
    
    enum Error: Swift.Error {
        case listNotFound
    }
}
