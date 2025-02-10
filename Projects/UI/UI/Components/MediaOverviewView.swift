import SwiftUI

public struct MediaOverviewView: View {
  let overview: String
  
  @State
  var isExpanded: Bool = false
  
  public init(overview: String) {
    self.overview = overview
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Overview:")
        .foregroundColor(.primary)
        .font(.headline)
        .lineLimit(1)

      Text(overview)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .lineLimit(isExpanded ? nil : 5)
      
      Button(action: {
        isExpanded.toggle()
      }) {
        Text(isExpanded ? "Less.." : "More..")
          .font(.caption)
      }
    }
  }
}
