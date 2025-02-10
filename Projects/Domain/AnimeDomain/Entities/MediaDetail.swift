import Foundation

public struct MediaDetail: Equatable {
    public let id: Int
    public let coverImage: String?
    public let genres: [String]
    public let duration: Int
    public let startDate: Date?
    public let popularity: Int
    public let averageScore: Int
    public let description: String
    public let bannerImage: String?
    public let characters: [Character]
    public let recommendations: [DiscoverMedia]
    public let title: String
    public let type: String
    public let trailerURL: URL?

    public init(
        id: Int,
        coverImage: String?,
        trailerURL: URL?,
        genres: [String],
        duration: Int,
        startDate: Date?,
        type: String,
        popularity: Int,
        averageScore: Int,
        description: String,
        bannerImage: String?,
        characters: [Character],
        title: String,
        recommendations: [DiscoverMedia]
    ) {
        self.id = id
        self.coverImage = coverImage
        self.trailerURL = trailerURL
        self.genres = genres
        self.duration = duration
        self.startDate = startDate
        self.popularity = popularity
        self.averageScore = averageScore
        self.description = description
        self.bannerImage = bannerImage
        self.characters = characters
        self.title = title
        self.type = type
        self.recommendations = recommendations
    }
}

public extension MediaDetail {
    struct Character: Equatable {
        public let id: Int
        public let name: String?
        public let image: String?

        public init(id: Int, name: String?, image: String?) {
            self.id = id
            self.name = name
            self.image = image
        }
    }

    struct RecommendedMedia: Equatable {
        public let id: Int
        public let title: String
        public let coverImage: String?

        public init(id: Int, title: String, coverImage: String?) {
            self.id = id
            self.title = title
            self.coverImage = coverImage
        }
    }
}
