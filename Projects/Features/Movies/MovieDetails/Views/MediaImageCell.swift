import MoviesDomain
import SwiftUI
import UI

struct MediaImageCell: View {
  let imageURL: URL
  let title: String
  let subtitle: String?

  var body: some View {
    VStack(alignment: .center) {
      PosterImageView(
        posterSize: .small,
        posterURL: imageURL
      )

      Text(title)
        .font(.footnote)
        .foregroundColor(.primary)
        .lineLimit(1)
      if let subtitle {
        Text(subtitle)
          .font(.footnote)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
    }
    .frame(width: 100)
    .contentShape(Rectangle())
  }
}

// person.character ?? person.job ?? person.department ?? ""
