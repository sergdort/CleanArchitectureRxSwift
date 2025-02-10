import SwiftUI
import MoviesDomain
import UI

public struct CustomListView: View {
  public let movieList: MovieList
  
  public init(movieList: MovieList) {
    self.movieList = movieList
  }
  
  public var body: some View {
    List(movieList.movies, id: \.id) { movie in
      MediaRow(
        title: movie.title,
        posterURL: movie.posterPath.map(ImageSize.medium.path(poster:)),
        score: Int(movie.voteAverage * 10),
        releaseDate: movie.releaseDate,
        overview: movie.overview
      )
    }
    .navigationTitle(movieList.name)
  }
}
