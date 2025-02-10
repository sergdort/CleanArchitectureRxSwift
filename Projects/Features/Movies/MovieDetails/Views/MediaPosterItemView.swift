import MoviesDomain
import SwiftUI
import UI

struct MediaPosterItemView: View {
  let posterURL: URL?
  let title: String

  var body: some View {
    VStack(alignment: .center) {
      PosterImageView(
        posterSize: .medium,
        posterURL: posterURL
      )

      Text(title)
        .font(.footnote)
        .foregroundColor(.primary)
        .lineLimit(1)
    }
    .frame(width: PosterStyle.Size.medium.width)
    .contentShape(Rectangle())
  }
}
