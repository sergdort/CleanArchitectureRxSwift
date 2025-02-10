import Foundation
import SwiftData
import AnimeDomain

@Model
final class SDMediaWatchlist {
    @Relationship
    var media: [SDDiscoverMedia]

    init(media: [SDDiscoverMedia]) {
        self.media = media
    }
}

@Model
final class SDMediaSeenlist {
    @Relationship
    var media: [SDDiscoverMedia]

    init(media: [SDDiscoverMedia]) {
        self.media = media
    }
}

@Model
final class SDMediaList {
    var listID: UUID
    var name: String
    var imagePath: String?

    @Relationship
    var media: [SDDiscoverMedia]

    init(
        listID: UUID = .init(),
        name: String,
        imagePath: String?,
        media: [SDDiscoverMedia]
    ) {
        self.listID = listID
        self.name = name
        self.imagePath = imagePath
        self.media = media
    }
}

extension SDMediaWatchlist {
    var toDomain: MediaWatchlist {
        MediaWatchlist(
            media: media.map(\.toDomain)
        )
    }
}

extension SDMediaSeenlist {
    var toDomain: MediaSeenlist {
        MediaSeenlist(
            media: media.map(\.toDomain)
        )
    }
}
