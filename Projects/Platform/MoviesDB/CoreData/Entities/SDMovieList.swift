import Foundation
import SwiftData
import MoviesDomain

@Model
final class SDMovieWatchlist {
    @Attribute(.unique)
    private var listID = 1
    
    @Relationship
    var movies: [SDMovie]

    init(movies: [SDMovie]) {
        self.movies = movies
    }
    
    var toDomain: MovieWatchlist {
        MovieWatchlist(movies: movies.map(\.toDomain))
    }
}

@Model
final class SDMovieSeenList {
    @Attribute(.unique)
    private var listID = 1
    
    @Relationship
    var movies: [SDMovie]

    init(movies: [SDMovie]) {
        self.movies = movies
    }
    
    var toDomain: MovieSeenList {
        MovieSeenList(movies: movies.map(\.toDomain))
    }
}

@Model
final class SDMovieList {
    @Attribute(.unique)
    private(set) var listID: String
    var name: String
    var imagePath: String?
    
    @Relationship
    var movies: [SDMovie]
    var createdAt: Date

    init(
        listID: String,
        name: String,
        imagePath: String?,
        movies: [SDMovie]
    ) {
        self.listID = listID
        self.name = name
        self.imagePath = imagePath
        self.movies = movies
        self.createdAt = Date()
    }
    
    var toDomain: MovieList {
        MovieList(
            id: UUID(uuidString: listID) ?? UUID(),
            name: name,
            imagePath: imagePath,
            movies: movies.map(\.toDomain)
        )
    }
}

extension SDMovieList {
    static func by(listID: String) -> Predicate<SDMovieList> {
        #Predicate {
            $0.listID == listID
        }
    }
}
