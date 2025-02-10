import Foundation

public struct MovieWatchlist: Codable {
    public var movies: [Movie]

    public init(movies: [Movie]) {
        self.movies = movies
    }
}

public struct MovieSeenList: Codable {
    public var movies: [Movie]

    public init(movies: [Movie]) {
        self.movies = movies
    }
}

public struct MovieList: Codable {
    public let id: UUID
    public var name: String
    public var imagePath: String?
    public var movies: [Movie]

    public init(
        id: UUID = .init(),
        name: String,
        imagePath: String?,
        movies: [Movie]
    ) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.movies = movies
    }
}
