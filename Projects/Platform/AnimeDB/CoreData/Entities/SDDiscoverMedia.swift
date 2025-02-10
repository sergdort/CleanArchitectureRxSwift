import AnimeDomain
import Foundation
import SwiftData

@Model
final class SDDiscoverMedia: Hashable {
    var mediaID: Int
    var startDate: Date?
    var endDate: Date?
    var coverImageURL: URL?
    var title: String
    var mediaDescription: String
    var averageScore: Int
    
    @Relationship(inverse: \SDMediaWatchlist.media)
    var watchlist: SDMediaWatchlist?
    
    var seenlist: SDMediaSeenlist?

    init(
        mediaID: Int,
        startDate: Date?,
        endDate: Date?,
        coverImageURL: URL?,
        title: String,
        mediaDescription: String,
        averageScore: Int
    ) {
        self.mediaID = mediaID
        self.startDate = startDate
        self.endDate = endDate
        self.coverImageURL = coverImageURL
        self.title = title
        self.mediaDescription = mediaDescription
        self.averageScore = averageScore
    }
}

extension DiscoverMedia {
    var toSDMedia: SDDiscoverMedia {
        SDDiscoverMedia(
            mediaID: id,
            startDate: startDate,
            endDate: endDate,
            coverImageURL: coverImageURL,
            title: title,
            mediaDescription: description,
            averageScore: averageScore
        )
    }
}

extension SDDiscoverMedia {
    var toDomain: DiscoverMedia {
        DiscoverMedia(
            id: mediaID,
            startDate: startDate,
            endDate: endDate,
            coverImageURL: coverImageURL,
            title: title,
            description: mediaDescription,
            averageScore: averageScore
        )
    }
}
