import AnimeDomain
import ComposableArchitecture
import SwiftUI
import UI

public struct AnimeListView: View {
    let store: StoreOf<AnimeListReducer>

    public init(store: StoreOf<AnimeListReducer>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.media, id: \.id) { anime in
                MediaRow(
                    title: anime.title,
                    posterURL: anime.coverImageURL,
                    score: anime.averageScore,
                    releaseDate: anime.startDate,
                    overview: anime.description
                )
                .onTapGesture {
                    store.send(.didSelectMedia(anime))
                }
            }
        }
        .onAppear {
            store.send(.loadData)
        }
        .listStyle(.plain)
        .navigationTitle(store.genre ?? store.mediaType.name)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu("Media type", systemImage: store.mediaType.imageName) {
                    ForEach(MediaType.allCases, id: \.self) { type in
                        Button(action: {
                            store.send(.setMediaType(type))
                        }) {
                            HStack {
                                Text(type.name)
                                if type == store.mediaType {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Sort", systemImage: "slider.horizontal.3") {
                    ForEach(DiscoverAnimeFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            store.send(.setFilter(filter))
                        }) {
                            HStack {
                                Text(filter.name)
                                if filter == store.filter {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension MediaType {
    var name: String {
        switch self {
        case .anime:
            "Anime"
        case .manga:
            "Manga"
        }
    }
    
    var imageName: String {
        switch self {
        case .anime:
            "sparkles.rectangle.stack"
        case .manga:
            "sparkles.square.filled.on.square"
        }
    }
}

extension DiscoverAnimeFilter {
    var name: String {
        switch self {
        case .allTimePopular:
            "Most popular"
        case .trending:
            "Treding"
        case .topRated:
            "Top rated"
        }
    }
}
