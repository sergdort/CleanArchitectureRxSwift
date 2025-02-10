import Foundation

public struct MovieDetail: Equatable, Decodable {
    public var adult: Bool
    public var backdropPath: String?
    public var belongsToCollection: Collection?
    public var budget: Int
    public var genres: [Genre]?
    public var homepage: String?
    public var id: MovieID
    public var originCountry: [String]
    public var originalLanguage: String
    public var originalTitle: String
    public var overview: String
    public var popularity: Double
    public var posterPath: String?
    public var productionCompanies: [ProductionCompany]?
    public var productionCountries: [ProductionCountry]?
    public var releaseDate: Date
    public var revenue: Int
    public var runtime: Int
    public var spokenLanguages: [SpokenLanguage]
    public var status: String
    public var tagline: String
    public var title: String
    public var video: Bool
    public var voteAverage: Double
    public var voteCount: Int
    public var keywords: Keywords?
}

public extension MovieDetail {
    struct Collection: Equatable, Decodable {
        public var id: Int
        public var name: String
        public var posterPath: String?
        public var backdropPath: String?
    }
    
    struct Genre: Equatable, Decodable {
        public var id: Int
        public var name: String
    }
    
    struct ProductionCompany: Equatable, Decodable {
        public var id: Int
        public var logoPath: String?
        public var name: String
        public var originCountry: String
    }
    
    struct ProductionCountry: Equatable, Decodable {
        public var iso3166_1: String?
        public var name: String
    }
    
    struct SpokenLanguage: Equatable, Decodable {
        public var englishName: String
        public var name: String
    }
    
    struct Keywords: Codable, Hashable {
        public var keywords: [Keyword]?
    }
}
