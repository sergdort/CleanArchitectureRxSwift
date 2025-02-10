import Foundation

public protocol DicoverMoviesRepository {
    func movies(for reuqest: DiscoverMoviesRequest) throws -> [Movie]
    
    func save(movies: [Movie], for request: DiscoverMoviesRequest) throws
}
