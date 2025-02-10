import Dependencies
import MoviesDomain
import SwiftUI
import UI

public struct MoviesListView: View {
    let viewModel: MoviesViewModel

    public init(viewModel: MoviesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            ForEach(viewModel.movies, id: \.id) { movie in
                MediaRow(
                    title: movie.title,
                    posterURL: movie.posterPath.map(ImageSize.medium.path(poster:)),
                    score: Int(movie.voteAverage * 10),
                    releaseDate: movie.releaseDate,
                    overview: movie.overview
                )
                .onTapGesture {
                    viewModel.didSelect(movie: movie)
                }
            }
        }
        .listStyle(.plain)
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Filter Movies", systemImage: "slider.horizontal.3") {
                    ForEach(DiscoverMoviesRequest.allCases, id: \.self) { request in
                        Button(action: {
                            viewModel.filter(request: request)
                        }) {
                            HStack {
                                Text(request.name)
                                if request == viewModel.request {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                    }
                }
            }
        })
        .task {
            await viewModel.fetch()
        }
    }
}

extension DiscoverMoviesRequest {
    var name: String {
        switch self {
        case .nowPlaying:
            "Now Playing"
        case .popular:
            "Popular"
        case .topRated:
            "Top Rated"
        case .upcoming:
            "Upcoming"
        }
    }
}
