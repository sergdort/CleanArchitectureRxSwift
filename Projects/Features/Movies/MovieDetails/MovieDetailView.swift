import Dependencies
import MoviesDomain
import SwiftUI
import UI

public struct MovieDetailView: View {
    private let viewModel: MovieDetailViewModel

    public init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if let movieDetails = viewModel.props.details, let cast = viewModel.props.cast {
                render(detail: movieDetails, cast: cast, recommended: viewModel.props.recommended, similar: viewModel.props.similar)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(viewModel.movie.title)
        .task {
            await viewModel.fetchDetails()
        }
    }

    @ViewBuilder
    private func render(
        detail: MovieDetail,
        cast: MovieCast,
        recommended: [Movie],
        similar: [Movie]
    ) -> some View {
        List {
            Section {
                MoviePosterRow(detail: detail)
                MediaButtonsRow(
                    isWatchlistSelected: viewModel.props.isInWatchlist,
                    isSeenlistSelected: viewModel.props.isInSeenlist,
                    isListSelected: viewModel.props.isInCustomList,
                    didTapWatchlist: viewModel.addToWatchlist,
                    didTapSeenlist: viewModel.addToSeenList,
                    didTapList: viewModel.didTapList
                )
                MediaOverviewView(overview: detail.overview)
            }
            Section {
                MovieKeywordsRow(keywords: detail.keywords?.keywords ?? [])
                if cast.cast.isEmpty == false {
                    MediaCrossLineItemsRow(
                        title: "Cast:",
                        posterSize: .small,
                        items: cast.cast.map { person in
                            MediaCrossLineItemsRow.Item(
                                id: person.renderingId,
                                imageURL: person.profilePath.map(ImageSize.small.path(poster:)),
                                title: person.name,
                                subtitle: person.character ?? person.job ?? person.department ?? "",
                                didTap: {
                                    viewModel.didTap(person: person)
                                }
                            )
                        }
                    )
                }
                if cast.crew.isEmpty == false {
                    MediaCrossLineItemsRow(
                        title: "Crew:",
                        posterSize: .small,
                        items: cast.crew.map { person in
                            MediaCrossLineItemsRow.Item(
                                id: person.renderingId,
                                imageURL: person.profilePath.map(ImageSize.small.path(poster:)),
                                title: person.name,
                                subtitle: person.character ?? person.job ?? person.department ?? "",
                                didTap: {
                                    viewModel.didTap(person: person)
                                }
                            )
                        }
                    )
                }
                if recommended.isEmpty == false {
                    MediaCrossLineItemsRow(
                        title: "Recommended:",
                        posterSize: .medium,
                        items: recommended.map { movie in
                            MediaCrossLineItemsRow.Item(
                                id: "\(movie.id.rawValue)",
                                imageURL: movie.posterPath.map(ImageSize.medium.path(poster:)),
                                title: movie.title,
                                didTap: {
                                    viewModel.didTap(movie: movie)
                                }
                            )
                        }
                    )
                }
                if similar.isEmpty == false {
                    MediaCrossLineItemsRow(
                        title: "Similar:",
                        posterSize: .medium,
                        items: similar.map { movie in
                            MediaCrossLineItemsRow.Item(
                                id: "\(movie.id.rawValue)",
                                imageURL: movie.posterPath.map(ImageSize.medium.path(poster:)),
                                title: movie.title,
                                didTap: {
                                    viewModel.didTap(movie: movie)
                                }
                            )
                        }
                    )
                }
            }
        }
    }
}

extension Person {
    var renderingId: String {
        "\(id)+\(department ?? "none")+\(job ?? "none") \(character ?? "")"
    }
}
