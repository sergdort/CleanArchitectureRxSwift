import Foundation

public struct Media {
    public let uid: String
    public let type: MediaType
    public let url: URL
    
    public init(uid: String, type: MediaType, url: URL) {
        self.uid = uid
        self.type = type
        self.url = url
    }
}

public enum MediaType: String {
    case photo = "photo"
    case video = "video"
}

extension Media: Equatable {
    public static func == (lhs: Media, rhs: Media) -> Bool {
            return lhs.uid == rhs.uid &&
                lhs.type == rhs.type &&
                lhs.url == rhs.url
    }
}
