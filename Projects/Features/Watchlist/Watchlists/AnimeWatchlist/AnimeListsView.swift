import AnimeDomain
import SwiftUI
import UI

struct AnimeListsView: View {
    @State
    private var selection: Selection = .wathclist
    
    let viewModel: AnimeListsViewModel
    
    init(viewModel: AnimeListsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Picker(selection: $selection, label: Text("")) {
                Text("Wishlist")
                    .tag(Selection.wathclist)
        
                Text("Seenlist")
                    .tag(Selection.seenlist)
            }
            .pickerStyle(SegmentedPickerStyle())
      
            switch selection {
            case .wathclist:
                renderWatchlist()
            case .seenlist:
                renderSeenlist()
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            viewModel.fetch()
        }
    }
    
    private func renderWatchlist() -> some View {
        Section(header: Text("Watchlist")) {
            if let watchlist = viewModel.props.watchlist, watchlist.media.isEmpty == false {
                ForEach(watchlist.media, id: \.id) { media in
                    MediaRow(
                        title: media.title,
                        posterURL: media.coverImageURL,
                        score: media.averageScore,
                        releaseDate: media.startDate,
                        overview: media.description
                    )
                }
            } else {
                ContentUnavailableView(
                    label: {
                        Text("No movies in your watchlist.")
                    },
                    description: {
                        Text("Add some movies to your watchlist to see them here.")
                    }
                )
            }
        }
    }
    
    private func renderSeenlist() -> some View {
        Section(header: Text("Seenlist")) {
            if let seenlist = self.viewModel.props.seenlist, seenlist.media.isEmpty == false {
                ForEach(seenlist.media, id: \.id) { media in
                    MediaRow(
                        title: media.title,
                        posterURL: media.coverImageURL,
                        score: media.averageScore,
                        releaseDate: media.startDate,
                        overview: media.description
                    )
                }
            } else {
                ContentUnavailableView(
                    label: {
                        Text("No movies in your seenlist.")
                    },
                    description: {
                        Text("Add some movies to your seenlist to see them here.")
                    }
                )
            }
        }

    }
    
    enum Selection {
        case wathclist
        case seenlist
    }
}
