import Foundation

public struct DiscoverMedia: Hashable {
    public let id: Int
    public let startDate: Date?
    public let endDate: Date?
    public let coverImageURL: URL?
    public let title: String
    public let description: String
    public let averageScore: Int

    public init(
        id: Int,
        startDate: Date?,
        endDate: Date?,
        coverImageURL: URL?,
        title: String,
        description: String,
        averageScore: Int
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.coverImageURL = coverImageURL
        self.title = title
        self.description = description
        self.averageScore = averageScore
    }
}

public enum DiscoverAnimeFilter: Hashable, CaseIterable {
    case allTimePopular
    case trending
    case topRated
}

public enum MediaType: Hashable, CaseIterable {
    case anime
    case manga
}

#if DEBUG

extension DiscoverMedia {
    public static var sample: DiscoverMedia {
        DiscoverMedia(
            id: 1,
            startDate: Date(),
            endDate: Date(),
            coverImageURL: URL(string: "ttps://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx1-CXtrrkMpJ8Zq.png"),
            title: "Cowboy Bebop",
            description: """
            Enter a world in the distant future, where Bounty Hunters roam the solar system. Spike and Jet, bounty hunting partners, set out on journeys in an ever struggling effort to win bounty rewards to survive.<br><br>\nWhile traveling, they meet up with other very interesting people. Could Faye, the beautiful and ridiculously poor gambler, Edward, the computer genius, and Ein, the engineered dog be a good addition to the group?
            """,
            averageScore: 86
        )
    }
}

#endif
