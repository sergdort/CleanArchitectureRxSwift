import AnimeDomain
import SwiftUI
import UI

struct AnimePosterRow: View {
    var detail: MediaDetail

    var didTapGenre: (String) -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            BackdropImageView(
                posterURL: detail.bannerImage.flatMap(URL.init(string:)), height: 250
            )
            .blur(radius: 30)

            VStack(alignment: .leading) {
                HStack {
                    PosterImageView(
                        posterSize: .medium,
                        posterURL: detail.coverImage.flatMap(URL.init(string:))
                    )
                    VStack(alignment: .leading) {
                        if let startDate = detail.startDate {
                            Text("\(Calendar.current.component(.year, from: startDate)) • \(detail.duration) min • \(detail.type)")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        Text(detail.title)
                            .foregroundStyle(.white)

                        HStack {
                            PopularityBadge(score: detail.averageScore)
                                .foregroundStyle(.white)
                            Text("Popularity: \(detail.popularity)")
                                .foregroundStyle(.white)
                        }
                    }
                }

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(detail.genres, id: \.self) { genre in
                            RoundedBadge(text: genre, color: .white)
                                .onTapGesture {
                                    didTapGenre(genre)
                                }
                        }
                    }
                }
            }
        }
    }
}
