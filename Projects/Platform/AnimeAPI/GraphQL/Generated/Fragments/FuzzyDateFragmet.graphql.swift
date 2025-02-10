// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct FuzzyDateFragmet: AnimeAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment FuzzyDateFragmet on FuzzyDate { __typename year month day }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimeAPI.Objects.FuzzyDate }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("year", Int?.self),
    .field("month", Int?.self),
    .field("day", Int?.self),
  ] }

  /// Numeric Year (2017)
  public var year: Int? { __data["year"] }
  /// Numeric Month (3)
  public var month: Int? { __data["month"] }
  /// Numeric Day (24)
  public var day: Int? { __data["day"] }
}
