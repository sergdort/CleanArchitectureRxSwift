import AnimeDomain
import Dependencies
import Foundation
import SwiftData
import SwiftDataHelpers

public final class SDMediaSeenlistRepository: MediaSeenlistUseCase {
    @Dependency(\.animeStore)
    private var store: Store
    private var seenlist: SDMediaSeenlist?
    
    public init() {}
    
    public func contains(media: DiscoverMedia) -> Bool {
        let seenlist = try? getSDSeenlist()
        return seenlist?.media.contains(where: { $0.mediaID == media.id }) ?? false
    }
    
    public func add(media: DiscoverMedia) throws -> AnimeDomain.MediaSeenlist {
        let seenlist = try getSDSeenlist()
        let mediID = media.id
        let predicate = #Predicate<SDDiscoverMedia> { $0.mediaID == mediID }
        let fetch = FetchDescriptor<SDDiscoverMedia>(predicate: predicate)
        if let sdMedia = try store.fetch(fetch).first {
            seenlist.media.append(sdMedia)
        } else {
            let sdMedia = media.toSDMedia
            seenlist.media.append(sdMedia)
        }
        try store.save()
        return seenlist.toDomain
    }
    
    public func remove(media: DiscoverMedia) throws -> AnimeDomain.MediaSeenlist {
        let seenlist = try getSDSeenlist()
        seenlist.media.removeAll(where: { $0.mediaID == media.id })
        try store.save()
        return seenlist.toDomain
    }
    
    public func getSeenList() throws -> MediaSeenlist {
        try getSDSeenlist().toDomain
    }
        
    func getSDSeenlist() throws -> SDMediaSeenlist {
        if let seenlist = self.seenlist {
            return seenlist
        }
        if let seenlist = try store.fetchAll(of: SDMediaSeenlist.self, sortBy: []).first {
            return seenlist
        }
        let seenlist = SDMediaSeenlist(media: [])
        self.seenlist = seenlist
        store.insert(seenlist)
        try store.save()
        return seenlist
    }
}
