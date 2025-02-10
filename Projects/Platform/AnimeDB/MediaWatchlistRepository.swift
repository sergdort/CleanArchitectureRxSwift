import Foundation
import AnimeDomain
import SwiftDataHelpers
import SwiftData
import Dependencies

public final class SDMediaWatchlistRepository: MediaWatchlistUseCase {
    @Dependency(\.animeStore)
    private var store: Store
    private var watchlist: SDMediaWatchlist?
    
    public init() {}
    
    public func contains(media: DiscoverMedia) -> Bool {
        let watchlist = try? getSDWatchlist()
        return watchlist?.media.contains(where: { $0.mediaID == media.id }) ?? false
    }
    
    @discardableResult
    public func add(media: DiscoverMedia) throws -> MediaWatchlist {
        let watchlist = try getSDWatchlist()
        if watchlist.media.contains(where: { media.id == $0.mediaID }) {
            return watchlist.toDomain
        }
        let mediaId = media.id
        let predicate = #Predicate<SDDiscoverMedia> {
            $0.mediaID == mediaId
        }
        let fetch = FetchDescriptor<SDDiscoverMedia>(predicate: predicate)
        if let sdMedia = try store.fetch(fetch).first {
            watchlist.media.append(sdMedia)
        } else {
            let sdMedia = media.toSDMedia
            watchlist.media.append(sdMedia)
        }
        try store.save()
        return watchlist.toDomain
    }
    
    @discardableResult
    public func remove(media: DiscoverMedia) throws -> MediaWatchlist {
        let watchlist = try getSDWatchlist()
        watchlist.media.removeAll(where: { $0.mediaID == media.id })
        try store.save()
        return watchlist.toDomain
    }
    
    public func getWatchlist() throws -> MediaWatchlist {
        try getSDWatchlist().toDomain
    }
    
    private func getSDWatchlist() throws -> SDMediaWatchlist {
        if let watchlist = self.watchlist {
            return watchlist
        }
        if let watchlist = try store.fetchAll(of: SDMediaWatchlist.self, sortBy: []).first {
            return watchlist
        }
        let watchlist = SDMediaWatchlist(media: [])
        self.watchlist = watchlist
        store.insert(watchlist)
        try store.save()
        return watchlist
    }
}
