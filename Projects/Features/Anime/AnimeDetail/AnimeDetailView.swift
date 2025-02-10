import AnimeDomain
import Dependencies
import SwiftUI
import UI
import ComposableArchitecture

public struct AnimeDetailView: View {
    private let store: StoreOf<AnimeDetailReducer>
    
    public init(store: StoreOf<AnimeDetailReducer>) {
        self.store = store
    }
    
    public var body: some View {
        Group {
            if let detail = store.mediaDetail {
                render(detail: detail)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(store.anime.title)
        .onViewDidLoad {
            store.send(.viewDidLoad)
        }
    }
    
    @ViewBuilder
    private func render(
        detail: MediaDetail
    ) -> some View {
        List {
            Section {
                AnimePosterRow(
                    detail: detail,
                    didTapGenre: { genre in
                        store.send(.didTapGenre(genre))
                    }
                )
                MediaButtonsRow(
                    isWatchlistSelected: store.isInWatchlist,
                    isSeenlistSelected: store.isInSeenlist,
                    isListSelected: false,
                    didTapWatchlist: {
                        store.send(.addToWatchlist)
                    },
                    didTapSeenlist: {
                        store.send(.addToSeenlist)
                    },
                    didTapList: { }
                )
                MediaOverviewView(overview: detail.description)
            }
            if let trailerURL = detail.trailerURL {
                Section {
                    VStack(alignment: .leading) {
                        Text("Trailer:")
                            .foregroundColor(.primary)
                            .font(.headline)
                        WebView(url: trailerURL)
                            .frame(height: 200)
                    }
                }
            }
            Section {
                if detail.characters.isEmpty == false {
                    MediaCrossLineItemsRow(
                        title: "Characters:",
                        posterSize: .small,
                        items: detail.characters.map { character in
                            MediaCrossLineItemsRow.Item(
                                id: "\(character.id)",
                                imageURL: character.image.flatMap(URL.init(string:)),
                                title: character.name ?? "",
                                subtitle: nil,
                                didTap: {}
                            )
                        }
                    )
                    if detail.recommendations.isEmpty == false {
                        MediaCrossLineItemsRow(
                            title: "Recomendations:",
                            posterSize: .medium,
                            items: detail.recommendations.map { media in
                                MediaCrossLineItemsRow.Item(
                                    id: "\(media.id)",
                                    imageURL: media.coverImageURL,
                                    title: media.title,
                                    subtitle: nil,
                                    didTap: {
                                        store.send(AnimeDetailReducer.Action.didTapMedia(media))
                                    }
                                )
                            }
                        )
                    }
                }
            }
        }
    }
}
