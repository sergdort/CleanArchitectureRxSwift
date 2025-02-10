// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MediaByIdQuery: GraphQLQuery {
  public static let operationName: String = "MediaById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MediaById($mediaId: Int) { Media(id: $mediaId) { __typename id coverImage { __typename large } duration startDate { __typename ...FuzzyDateFragmet } genres popularity averageScore description bannerImage characters { __typename nodes { __typename image { __typename medium } name { __typename full } id } } type title { __typename english } trailer { __typename site id } recommendations(page: 0, perPage: 15) { __typename nodes { __typename mediaRecommendation { __typename ...GQLDiscoverMedia } } } } }"#,
      fragments: [FuzzyDateFragmet.self, GQLDiscoverMedia.self]
    ))

  public var mediaId: GraphQLNullable<Int>

  public init(mediaId: GraphQLNullable<Int>) {
    self.mediaId = mediaId
  }

  public var __variables: Variables? { ["mediaId": mediaId] }

  public struct Data: AnimeAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("Media", Media?.self, arguments: ["id": .variable("mediaId")]),
    ] }

    /// Media query
    public var media: Media? { __data["Media"] }

    /// Media
    ///
    /// Parent Type: `Media`
    public struct Media: AnimeAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Media }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", Int.self),
        .field("coverImage", CoverImage?.self),
        .field("duration", Int?.self),
        .field("startDate", StartDate?.self),
        .field("genres", [String?]?.self),
        .field("popularity", Int?.self),
        .field("averageScore", Int?.self),
        .field("description", String?.self),
        .field("bannerImage", String?.self),
        .field("characters", Characters?.self),
        .field("type", GraphQLEnum<AnimeAPI.MediaType>?.self),
        .field("title", Title?.self),
        .field("trailer", Trailer?.self),
        .field("recommendations", Recommendations?.self, arguments: [
          "page": 0,
          "perPage": 15
        ]),
      ] }

      /// The id of the media
      public var id: Int { __data["id"] }
      /// The cover images of the media
      public var coverImage: CoverImage? { __data["coverImage"] }
      /// The general length of each anime episode in minutes
      public var duration: Int? { __data["duration"] }
      /// The first official release date of the media
      public var startDate: StartDate? { __data["startDate"] }
      /// The genres of the media
      public var genres: [String?]? { __data["genres"] }
      /// The number of users with the media on their list
      public var popularity: Int? { __data["popularity"] }
      /// A weighted average score of all the user's scores of the media
      public var averageScore: Int? { __data["averageScore"] }
      /// Short description of the media's story and characters
      public var description: String? { __data["description"] }
      /// The banner image of the media
      public var bannerImage: String? { __data["bannerImage"] }
      /// The characters in the media
      public var characters: Characters? { __data["characters"] }
      /// The type of the media; anime or manga
      public var type: GraphQLEnum<AnimeAPI.MediaType>? { __data["type"] }
      /// The official titles of the media in various languages
      public var title: Title? { __data["title"] }
      /// Media trailer or advertisement
      public var trailer: Trailer? { __data["trailer"] }
      /// User recommendations for similar media
      public var recommendations: Recommendations? { __data["recommendations"] }

      /// Media.CoverImage
      ///
      /// Parent Type: `MediaCoverImage`
      public struct CoverImage: AnimeAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.MediaCoverImage }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("large", String?.self),
        ] }

        /// The cover image url of the media at a large size
        public var large: String? { __data["large"] }
      }

      /// Media.StartDate
      ///
      /// Parent Type: `FuzzyDate`
      public struct StartDate: AnimeAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.FuzzyDate }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(FuzzyDateFragmet.self),
        ] }

        /// Numeric Year (2017)
        public var year: Int? { __data["year"] }
        /// Numeric Month (3)
        public var month: Int? { __data["month"] }
        /// Numeric Day (24)
        public var day: Int? { __data["day"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var fuzzyDateFragmet: FuzzyDateFragmet { _toFragment() }
        }
      }

      /// Media.Characters
      ///
      /// Parent Type: `CharacterConnection`
      public struct Characters: AnimeAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.CharacterConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        public var nodes: [Node?]? { __data["nodes"] }

        /// Media.Characters.Node
        ///
        /// Parent Type: `Character`
        public struct Node: AnimeAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Character }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("image", Image?.self),
            .field("name", Name?.self),
            .field("id", Int.self),
          ] }

          /// Character images
          public var image: Image? { __data["image"] }
          /// The names of the character
          public var name: Name? { __data["name"] }
          /// The id of the character
          public var id: Int { __data["id"] }

          /// Media.Characters.Node.Image
          ///
          /// Parent Type: `CharacterImage`
          public struct Image: AnimeAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.CharacterImage }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("medium", String?.self),
            ] }

            /// The character's image of media at medium size
            public var medium: String? { __data["medium"] }
          }

          /// Media.Characters.Node.Name
          ///
          /// Parent Type: `CharacterName`
          public struct Name: AnimeAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.CharacterName }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("full", String?.self),
            ] }

            /// The character's first and last name
            public var full: String? { __data["full"] }
          }
        }
      }

      /// Media.Title
      ///
      /// Parent Type: `MediaTitle`
      public struct Title: AnimeAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.MediaTitle }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("english", String?.self),
        ] }

        /// The official english title
        public var english: String? { __data["english"] }
      }

      /// Media.Trailer
      ///
      /// Parent Type: `MediaTrailer`
      public struct Trailer: AnimeAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.MediaTrailer }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("site", String?.self),
          .field("id", String?.self),
        ] }

        /// The site the video is hosted by (Currently either youtube or dailymotion)
        public var site: String? { __data["site"] }
        /// The trailer video id
        public var id: String? { __data["id"] }
      }

      /// Media.Recommendations
      ///
      /// Parent Type: `RecommendationConnection`
      public struct Recommendations: AnimeAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.RecommendationConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        public var nodes: [Node?]? { __data["nodes"] }

        /// Media.Recommendations.Node
        ///
        /// Parent Type: `Recommendation`
        public struct Node: AnimeAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Recommendation }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("mediaRecommendation", MediaRecommendation?.self),
          ] }

          /// The recommended media
          public var mediaRecommendation: MediaRecommendation? { __data["mediaRecommendation"] }

          /// Media.Recommendations.Node.MediaRecommendation
          ///
          /// Parent Type: `Media`
          public struct MediaRecommendation: AnimeAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Media }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(GQLDiscoverMedia.self),
            ] }

            /// The id of the media
            public var id: Int { __data["id"] }
            /// The first official release date of the media
            public var startDate: StartDate? { __data["startDate"] }
            /// The last official release date of the media
            public var endDate: EndDate? { __data["endDate"] }
            /// The cover images of the media
            public var coverImage: CoverImage? { __data["coverImage"] }
            /// The official titles of the media in various languages
            public var title: Title? { __data["title"] }
            /// Short description of the media's story and characters
            public var description: String? { __data["description"] }
            /// A weighted average score of all the user's scores of the media
            public var averageScore: Int? { __data["averageScore"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var gQLDiscoverMedia: GQLDiscoverMedia { _toFragment() }
            }

            /// Media.Recommendations.Node.MediaRecommendation.StartDate
            ///
            /// Parent Type: `FuzzyDate`
            public struct StartDate: AnimeAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.FuzzyDate }

              /// Numeric Year (2017)
              public var year: Int? { __data["year"] }
              /// Numeric Month (3)
              public var month: Int? { __data["month"] }
              /// Numeric Day (24)
              public var day: Int? { __data["day"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var fuzzyDateFragmet: FuzzyDateFragmet { _toFragment() }
              }
            }

            /// Media.Recommendations.Node.MediaRecommendation.EndDate
            ///
            /// Parent Type: `FuzzyDate`
            public struct EndDate: AnimeAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.FuzzyDate }

              /// Numeric Year (2017)
              public var year: Int? { __data["year"] }
              /// Numeric Month (3)
              public var month: Int? { __data["month"] }
              /// Numeric Day (24)
              public var day: Int? { __data["day"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var fuzzyDateFragmet: FuzzyDateFragmet { _toFragment() }
              }
            }

            public typealias CoverImage = GQLDiscoverMedia.CoverImage

            public typealias Title = GQLDiscoverMedia.Title
          }
        }
      }
    }
  }
}
