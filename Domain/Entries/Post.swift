import Foundation

public struct Post {
    public let body: String
    public let title: String
    public let uid: String
    public let userId: String

    public init(body: String,
                title: String,
                uid: String,
                userId: String) {
        self.body = body
        self.title = title
        self.uid = uid
        self.userId = userId
    }
}

extension Post: Equatable {
    public static func == (lhs: Post, rhs: Post) -> Bool {
            return lhs.uid == rhs.uid &&
                lhs.title == rhs.title && 
                lhs.body == rhs.body &&
                lhs.userId == rhs.userId
    }
}
