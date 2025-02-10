// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct GQLDiscoverMedia: AnimeAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment GQLDiscoverMedia on Media { __typename id startDate { __typename ...FuzzyDateFragmet } endDate { __typename ...FuzzyDateFragmet } coverImage { __typename large } title { __typename english native } description averageScore }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.Media }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", Int.self),
    .field("startDate", StartDate?.self),
    .field("endDate", EndDate?.self),
    .field("coverImage", CoverImage?.self),
    .field("title", Title?.self),
    .field("description", String?.self),
    .field("averageScore", Int?.self),
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

  /// StartDate
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

  /// EndDate
  ///
  /// Parent Type: `FuzzyDate`
  public struct EndDate: AnimeAPI.SelectionSet {
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

  /// CoverImage
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

  /// Title
  ///
  /// Parent Type: `MediaTitle`
  public struct Title: AnimeAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.MediaTitle }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("english", String?.self),
      .field("native", String?.self),
    ] }

    /// The official english title
    public var english: String? { __data["english"] }
    /// Official title in it's native language
    public var native: String? { __data["native"] }
  }
}
