import MoviesDomain
import SwiftUI

struct CrosslineMoviesRow: View {
  let title: String
  let movies: [Movie]
  let onTap: (Movie) -> Void

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .foregroundColor(.primary)
        .font(.headline)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack {
          ForEach(movies, id: \.id) { movie in
            MediaPosterItemView(
              posterURL: movie.posterPath.map(ImageSize.medium.path(poster:)),
              title: movie.title
            )
            .onTapGesture {
              onTap(movie)
            }
          }
        }
      }
    }
    .padding(.vertical)
  }
}
