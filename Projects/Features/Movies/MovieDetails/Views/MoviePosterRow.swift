import MoviesDomain
import SwiftUI
import UI

struct MoviePosterRow: View {
    var detail: MovieDetail

    var body: some View {
        ZStack(alignment: .leading) {
            BackdropImageView(
                posterURL: ImageSize.medium.path(poster: detail.backdropPath ?? ""),
                height: 250
            )
            .blur(radius: 30)

            VStack(alignment: .leading) {
                HStack {
                    PosterImageView(
                        posterSize: .medium,
                        posterURL: ImageSize.medium.path(poster: detail.posterPath ?? "")
                    )
                    VStack(alignment: .leading) {
                        Text("\(Calendar.current.component(.year, from: detail.releaseDate)) • \(detail.runtime) min • \(detail.status)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text(detail.title)
                            .foregroundStyle(.white)

                        HStack {
                            PopularityBadge(score: Int(detail.voteAverage * 10))
                                .foregroundStyle(.white)
                            Text("\(detail.voteCount) ratings")
                                .foregroundStyle(.white)
                        }
                    }
                }

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(detail.genres ?? [], id: \.id) { genre in
                            RoundedBadge(text: genre.name, color: .white)
                        }
                    }
                }
            }
        }
    }
}
