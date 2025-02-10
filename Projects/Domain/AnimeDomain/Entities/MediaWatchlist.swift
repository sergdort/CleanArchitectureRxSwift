import Foundation

public struct MediaWatchlist {
    public var media: [DiscoverMedia]

    public init(media: [DiscoverMedia]) {
        self.media = media
    }
}

public struct MediaSeenlist {
    public var media: [DiscoverMedia]

    public init(media: [DiscoverMedia]) {
        self.media = media
    }
}

public struct MediaList {
    public let id: UUID
    public var name: String
    public var imagePath: String?
    public var media: [DiscoverMedia]

    public init(
        id: UUID = .init(),
        name: String,
        imagePath: String?,
        media: [DiscoverMedia]
    ) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.media = media
    }
}
