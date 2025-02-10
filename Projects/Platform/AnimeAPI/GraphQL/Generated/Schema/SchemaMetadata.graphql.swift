// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == AnimeAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == AnimeAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == AnimeAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == AnimeAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return AnimeAPI.Objects.Query
    case "Page": return AnimeAPI.Objects.Page
    case "Media": return AnimeAPI.Objects.Media
    case "FuzzyDate": return AnimeAPI.Objects.FuzzyDate
    case "MediaCoverImage": return AnimeAPI.Objects.MediaCoverImage
    case "MediaTitle": return AnimeAPI.Objects.MediaTitle
    case "PageInfo": return AnimeAPI.Objects.PageInfo
    case "CharacterConnection": return AnimeAPI.Objects.CharacterConnection
    case "Character": return AnimeAPI.Objects.Character
    case "CharacterImage": return AnimeAPI.Objects.CharacterImage
    case "CharacterName": return AnimeAPI.Objects.CharacterName
    case "MediaTrailer": return AnimeAPI.Objects.MediaTrailer
    case "RecommendationConnection": return AnimeAPI.Objects.RecommendationConnection
    case "Recommendation": return AnimeAPI.Objects.Recommendation
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
