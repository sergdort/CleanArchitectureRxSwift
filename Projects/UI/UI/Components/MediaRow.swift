import SwiftUI

public struct MediaRow: View {
  let title: String
  let posterURL: URL?
  let score: Int
  let releaseDate: Date?
  let overview: String
  
  public init(title: String, posterURL: URL?, score: Int, releaseDate: Date?, overview: String) {
    self.title = title
    self.posterURL = posterURL
    self.score = score
    self.releaseDate = releaseDate
    self.overview = overview
  }
  
  public var body: some View {
    HStack {
      PosterImageView(
        posterSize: .medium,
        posterURL: posterURL
      )
      .fixedSize()
      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .font(.title)
          .foregroundColor(.orange)
          .lineLimit(2)
        HStack {
          PopularityBadge(score: score)
          Text(releaseDate.map(formatter.string(from:)) ?? "TBD")
            .font(.subheadline)
            .foregroundColor(.primary)
            .lineLimit(1)
        }
        Text(overview)
          .foregroundColor(.secondary)
          .lineLimit(3)
      }
      .padding(.leading, 8)
    }
    .padding(.top, 8)
    .padding(.bottom, 8)
    .contentShape(Rectangle())
  }

  public enum Size: String {
    case small = "https://image.tmdb.org/t/p/w154/"
    case medium = "https://image.tmdb.org/t/p/w500/"
    case cast = "https://image.tmdb.org/t/p/w185/"
    case original = "https://image.tmdb.org/t/p/original/"

    func path(poster: String) -> URL {
      return URL(string: rawValue)!.appendingPathComponent(poster)
    }
  }
}

private let formatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  return formatter
}()
