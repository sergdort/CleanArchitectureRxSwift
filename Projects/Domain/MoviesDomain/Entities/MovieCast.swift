import Foundation

public struct MovieCast: Codable, Equatable {
    public let id: Int
    public let cast: [Person]
    public let crew: [Person]
}
