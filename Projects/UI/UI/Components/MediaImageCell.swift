import SwiftUI

public struct MediaImageCell: View {
  public let imageURL: URL?
  public let title: String?
  public let subtitle: String?
  public let posterSize: PosterStyle.Size

  public init(imageURL: URL?, title: String?, subtitle: String?, posterSize: PosterStyle.Size = .small) {
    self.imageURL = imageURL
    self.title = title
    self.subtitle = subtitle
    self.posterSize = posterSize
  }
  
  public var body: some View {
    VStack(alignment: .center) {
      PosterImageView(
        posterSize: posterSize,
        posterURL: imageURL
      )
      if let title {
        Text(title)
          .font(.footnote)
          .foregroundColor(.primary)
          .lineLimit(1)
      }
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
