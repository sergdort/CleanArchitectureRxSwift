import Foundation

public enum ImageSize: String {
  case small = "https://image.tmdb.org/t/p/w154/"
  case medium = "https://image.tmdb.org/t/p/w500/"
  case cast = "https://image.tmdb.org/t/p/w185/"
  case original = "https://image.tmdb.org/t/p/original/"

  func path(poster: String) -> URL {
    return URL(string: rawValue)!.appendingPathComponent(poster)
  }
}
