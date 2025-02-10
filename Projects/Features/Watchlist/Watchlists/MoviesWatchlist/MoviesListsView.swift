import Dependencies
import MoviesDomain
import SwiftUI
import UI

public struct MoviesListsView: View {
    let viewModel: MoviesListsViewModel
  
    @State
    private var selectedList: Selection = .wathclist
  
    public init(viewModel: MoviesListsViewModel) {
        self.viewModel = viewModel
    }
  
    public var body: some View {
        List {
            renderCustomLists()
      
            Picker(selection: $selectedList, label: Text("")) {
                Text("Wishlist")
                    .tag(Selection.wathclist)
        
                Text("Seenlist")
                    .tag(Selection.seenlist)
            }
            .pickerStyle(SegmentedPickerStyle())
      
            switch selectedList {
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
  
    func renderCustomLists() -> some View {
        Section(header: Text("Custom Lists")) {
            Button(action: viewModel.didTapCreateCustomList) {
                Text("Create custom list")
            }
            ForEach(viewModel.props.customLists, id: \.id) { customList in
                MovieListRow(list: customList)
                    .onTapGesture {
                        viewModel.didTap(customList: customList)
                    }
            }
        }
    }
  
    @ViewBuilder
    func renderWatchlist() -> some View {
        Section(header: Text("Watchlist")) {
            if let watchlist = viewModel.props.watchlist, watchlist.movies.isEmpty == false {
                ForEach(watchlist.movies, id: \.id) { movie in
                    MediaRow(
                        title: movie.title,
                        posterURL: movie.posterPath.map(ImageSize.medium.path(poster:)),
                        score: Int(movie.voteAverage * 10),
                        releaseDate: movie.releaseDate,
                        overview: movie.overview
                    )
                    .onTapGesture {
                        viewModel.didTap(movie: movie)
                    }
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
  
    @ViewBuilder
    func renderSeenlist() -> some View {
        Section(header: Text("Seenlist")) {
            if let seenList = self.viewModel.props.seenList, seenList.movies.isEmpty == false {
                ForEach(seenList.movies, id: \.id) { movie in
                    MediaRow(
                        title: movie.title,
                        posterURL: movie.posterPath.map(ImageSize.medium.path(poster:)),
                        score: Int(movie.voteAverage * 10),
                        releaseDate: movie.releaseDate,
                        overview: movie.overview
                    )
                    .onTapGesture {
                        viewModel.didTap(movie: movie)
                    }
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

struct MovieListRow: View {
    var list: MovieList
  
    var body: some View {
        HStack {
            BackdropImageView(posterURL: list.imagePath
                .map(ImageSize.medium.path(poster:))
            )
            .frame(width: 70, height: 42)
            Text(list.name)
                .font(.headline)
            Spacer()
            Text("\(list.movies.count) movies")
                .font(.caption)
        }
        .contentShape(Rectangle())
    }
}

// TOOD: extract this type with real endpoints
public enum ImageSize: String {
    case small = "https://image.tmdb.org/t/p/w154/"
    case medium = "https://image.tmdb.org/t/p/w500/"
    case cast = "https://image.tmdb.org/t/p/w185/"
    case original = "https://image.tmdb.org/t/p/original/"

    func path(poster: String) -> URL {
        return URL(string: rawValue)!.appendingPathComponent(poster)
    }
}
