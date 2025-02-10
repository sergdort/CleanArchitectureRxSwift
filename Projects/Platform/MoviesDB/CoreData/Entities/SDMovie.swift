import Foundation
import MoviesDomain
import SwiftData
import Tagged

@Model
final class SDMovie {
    @Attribute(.unique) var movieId: Int
    
    var adult: Bool
    var backdropPath: String?
    var overview: String
    var popularity: Double
    var posterPath: String?
    var releaseDate: Date?
    var title: String
    var video: Bool
    var voteAverage: Double
    var voteCount: Int
    
    @Relationship(inverse: \SDMovieWatchlist.movies)
    var watchlist: SDMovieWatchlist?
    
    @Relationship(inverse: \SDMovieSeenList.movies)
    var seenlist: SDMovieSeenList?
    
    @Relationship(inverse: \SDMovieList.movies)
    var lists: [SDMovieList] = []

    init(adult: Bool, backdropPath: String?, movieId: Int, overview: String, popularity: Double, posterPath: String?, releaseDate: Date?, title: String, video: Bool, voteAverage: Double, voteCount: Int) {
        self.adult = adult
        self.backdropPath = backdropPath
        self.movieId = movieId
        self.overview = overview
        self.popularity = popularity
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.title = title
        self.video = video
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
}

extension SDMovie {
    var toDomain: Movie {
        Movie(
            adult: adult,
            backdropPath: backdropPath,
            id: .init(movieId),
            overview: overview,
            popularity: popularity,
            posterPath: posterPath,
            releaseDate: releaseDate,
            title: title,
            video: video,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
    
    
    static func by(movieId: Int) -> Predicate<SDMovie> {
        #Predicate {
            $0.movieId == movieId
        }
    }
}

extension Movie {
    var toSDMovie: SDMovie {
        SDMovie(
            adult: adult,
            backdropPath: backdropPath,
            movieId: id.rawValue,
            overview: overview,
            popularity: popularity,
            posterPath: posterPath,
            releaseDate: releaseDate,
            title: title,
            video: video,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
}
