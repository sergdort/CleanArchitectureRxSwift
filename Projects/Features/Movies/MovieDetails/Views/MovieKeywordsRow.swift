//
import MoviesDomain
import SwiftUI
import UI

struct MovieKeywordsRow: View {
    var keywords: [Keyword]
    var body: some View {
        if keywords.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                Text("Keywords:")
                    .foregroundColor(.primary)
                    .font(.headline)

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(keywords, id: \.id) { keyword in
                            RoundedBadge(
                                text: keyword.name, color: Color(uiColor: UIColor.tertiarySystemFill)
                            )
                        }
                    }
                }
            }
        }
    }
}
