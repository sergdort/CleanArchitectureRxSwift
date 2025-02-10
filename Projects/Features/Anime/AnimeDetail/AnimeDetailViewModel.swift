import AnimeDomain
import Dependencies
import SwiftUI
import UI

@MainActor
@Observable
public final class AnimeDetailViewModel {
    struct Props {
        var detail: MediaDetail?
        var isInWatchlist = false
        var isInSeenlist = false
    }
    
    @ObservationIgnored
    @Dependency(\.animeDetailUseCase)
    private var animeDetailUseCase: AnimeDetailUseCase
    
    @ObservationIgnored
    @Dependency(\.mediaWatchlistUseCase)
    private var mediaWatchlistUseCase: MediaWatchlistUseCase
    
    @ObservationIgnored
    @Dependency(\.mediaSeenlistUseCase)
    private var mediaSeenlistUseCase: MediaSeenlistUseCase
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    @ObservationIgnored
    private let coordinator: AnimeCoordinator
    
    @ObservationIgnored
    public let anime: DiscoverMedia
    
    var props = Props()
    
    public init(anime: DiscoverMedia, coordinator: AnimeCoordinator) {
        self.anime = anime
        self.coordinator = coordinator
    }
    
    @MainActor
    func fetch() async {
        do {
            let detail = try await animeDetailUseCase.fetchBy(id: anime.id)
            props.isInWatchlist = mediaWatchlistUseCase.contains(media: anime)
            props.isInSeenlist = mediaSeenlistUseCase.contains(media: anime)
            props.detail = detail
        } catch {
            errorToast.show()
        }
    }
  
    func addToWatchlist() {
        if props.isInWatchlist {
            do {
                try mediaWatchlistUseCase.remove(media: anime)
                props.isInWatchlist = false
            } catch {
                errorToast.show()
            }
        } else {
            do {
                try mediaWatchlistUseCase.add(media: anime)
                props.isInWatchlist = true
            } catch {
                errorToast.show()
            }
        }
    }
  
    func addToSeenlist() {
        if props.isInSeenlist {
            do {
                try mediaSeenlistUseCase.remove(media: anime)
                props.isInSeenlist = false
            } catch {
                errorToast.show()
            }
        } else {
            do {
                try mediaSeenlistUseCase.add(media: anime)
                props.isInSeenlist = true
            } catch {
                errorToast.show()
            }
        }
    }
  
    func didTapList() {}
    
    func didTap(genre: String) {
        coordinator.showMedia(for: genre)
    }
    
    func didTap(media: DiscoverMedia) {
        coordinator.showDetails(for: media)
    }
}
