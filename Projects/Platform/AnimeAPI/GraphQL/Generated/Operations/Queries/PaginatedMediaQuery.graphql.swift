// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PaginatedMediaQuery: GraphQLQuery {
  public static let operationName: String = "PaginatedMedia"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query PaginatedMedia($page: Int, $perPage: Int, $mediaSort: [MediaSort], $type: MediaType, $genreIn: [String]) { Page(page: $page, perPage: $perPage) { __typename media(sort: $mediaSort, type: $type, genre_in: $genreIn) { __typename ...GQLDiscoverMedia } pageInfo { __typename currentPage hasNextPage } } }"#,
      fragments: [FuzzyDateFragmet.self, GQLDiscoverMedia.self]
    ))

  public var page: GraphQLNullable<Int>
  public var perPage: GraphQLNullable<Int>
  public var mediaSort: GraphQLNullable<[GraphQLEnum<MediaSort>?]>
  public var type: GraphQLNullable<GraphQLEnum<MediaType>>
  public var genreIn: GraphQLNullable<[String?]>

  public init(
    page: GraphQLNullable<Int>,
    perPage: GraphQLNullable<Int>,
    mediaSort: GraphQLNullable<[GraphQLEnum<MediaSort>?]>,
    type: GraphQLNullable<GraphQLEnum<MediaType>>,
    genreIn: GraphQLNullable<[String?]>
  ) {
    self.page = page
    self.perPage = perPage
    self.mediaSort = mediaSort
    self.type = type
    self.genreIn = genreIn
  }

  public var __variables: Variables? { [
    "page": page,
    "perPage": perPage,
    "mediaSort": mediaSort,
    "type": type,
    "genreIn": genreIn
  ] }

  public struct Data: AnimeAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("Page", Page?.self, arguments: [
        "page": .variable("page"),
        "perPage": .variable("perPage")
      ]),
    ] }

    public var page: Page? { __data["Page"] }

    /// Page
    ///
    /// Parent Type: `Page`
    public struct Page: AnimeAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Page }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("media", [Medium?]?.self, arguments: [
          "sort": .variable("mediaSort"),
          "type": .variable("type"),
          "genre_in": .variable("genreIn")
        ]),
        .field("pageInfo", PageInfo?.self),
      ] }

      public var media: [Medium?]? { __data["media"] }
      /// The pagination information
      public var pageInfo: PageInfo? { __data["pageInfo"] }

      /// Page.Medium
      ///
      /// Parent Type: `Media`
      public struct Medium: AnimeAPI.SelectionSet {
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

        /// Page.Medium.StartDate
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

        /// Page.Medium.EndDate
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

      /// Page.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: AnimeAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("currentPage", Int?.self),
          .field("hasNextPage", Bool?.self),
        ] }

        /// The current page
        public var currentPage: Int? { __data["currentPage"] }
        /// If there is another page
        public var hasNextPage: Bool? { __data["hasNextPage"] }
      }
    }
  }
}
