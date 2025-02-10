import SwiftUI

public struct MediaCrossLineItemsRow: View {
  let title: String
  let posterSize: PosterStyle.Size
  let items: [Item]

  public init(
    title: String,
    posterSize: PosterStyle.Size,
    items: [Item]
  ) {
    self.title = title
    self.items = items
    self.posterSize = posterSize
  }
  
  public var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .foregroundColor(.primary)
        .font(.headline)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack {
          ForEach(items, id: \.id) { (item) in
            MediaImageCell(
              imageURL: item.imageURL,
              title: item.title,
              subtitle: item.subtitle,
              posterSize: posterSize
            )
            .onTapGesture {
              item.didTap()
            }
          }
        }
      }
    }
    .padding(.vertical)
    .contentShape(Rectangle())
  }

  public struct Item {
    public let id: String
    public let imageURL: URL?
    public let title: String?
    public let subtitle: String?
    public let didTap: () -> Void
    
    public init(
      id: String,
      imageURL: URL?,
      title: String? = nil,
      subtitle: String? = nil,
      didTap: @escaping () -> Void
    ) {
      self.id = id
      self.imageURL = imageURL
      self.title = title
      self.subtitle = subtitle
      self.didTap = didTap
    }
  }
}
