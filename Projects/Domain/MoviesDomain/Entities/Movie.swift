import Foundation
import Tagged

public typealias MovieID = Tagged<Movie, Int>

public struct Movie: Hashable, Codable {
    public var adult: Bool
    public var backdropPath: String?
    public var id: MovieID
    public var overview: String
    public var popularity: Double
    public var posterPath: String?
    @SafeDateDecoding
    public var releaseDate: Date?
    public var title: String
    public var video: Bool
    public var voteAverage: Double
    public var voteCount: Int

    public init(adult: Bool, backdropPath: String?, id: MovieID, overview: String, popularity: Double, posterPath: String?, releaseDate: Date?, title: String, video: Bool, voteAverage: Double, voteCount: Int) {
        self.adult = adult
        self.backdropPath = backdropPath
        self.id = id
        self.overview = overview
        self.popularity = popularity
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.title = title
        self.video = video
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case id
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

#if DEBUG
extension Movie {
    static let formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        return formatter
    }()

    public static var sample: Movie {
        Movie(
            adult: false,
            backdropPath: "/stKGOm8UyhuLPR9sZLjs5AkmncA.jpg",
            id: 1022789,
            overview: """
            Teenager Riley's mind headquarters is undergoing a sudden demolition to make room for something entirely unexpected: new Emotions! Joy, Sadness, Anger, Fear and Disgust, who’ve long been running a successful operation by all accounts, aren’t sure how to feel when Anxiety shows up. And it looks like she’s not alone.
            """,
            popularity: 3553.5,
            posterPath: "/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg",
            releaseDate: Movie.formatter.date(from: "2024-06-11") ?? Date(),
            title: "Inside Out 2",
            video: false,
            voteAverage: 7.591,
            voteCount: 115
        )
    }
}
#endif

public extension CodingUserInfoKey {
    static let dateFormatter = CodingUserInfoKey(rawValue: "dateFormatter")!
}

@propertyWrapper
public struct SafeDateDecoding: Codable, Hashable {
    public var wrappedValue: Date?

    public init(wrappedValue: Date? = nil) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let dateFormatter = decoder.userInfo[.dateFormatter] as? DateFormatter else {
            throw DecodingError.valueNotFound(
                DateFormatter.self,
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "DateFormatter is not set in userInfo"
                )
            )
        }
        self.wrappedValue = string.isEmpty ? nil : dateFormatter.date(from: string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let dateFormatter = encoder.userInfo[.dateFormatter] as? DateFormatter else {
            throw DecodingError.valueNotFound(
                DateFormatter.self,
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "DateFormatter is not set in userInfo"
                )
            )
        }
        try container.encode(wrappedValue.map(dateFormatter.string(from:)) ?? "")
    }
}
