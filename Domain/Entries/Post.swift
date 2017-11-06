import Foundation

public struct Post {
    public let body: String
    public let title: String
    public let uid: String
    public let userId: String
    public let createdAt: String

    public init(body: String,
                title: String,
                uid: String,
                userId: String,
                createdAt: String) {
        self.body = body
        self.title = title
        self.uid = uid
        self.userId = userId
        self.createdAt = createdAt
    }

    public init(body: String, title: String) {
        self.init(body: body, title: title, uid: NSUUID().uuidString, userId: "5", createdAt: String(round(Date().timeIntervalSince1970 * 1000)))
    }
}

extension Post: Equatable {
    public static func == (lhs: Post, rhs: Post) -> Bool {
            return lhs.uid == rhs.uid &&
                lhs.title == rhs.title && 
                lhs.body == rhs.body &&
                lhs.userId == rhs.userId &&
                lhs.createdAt == rhs.createdAt
    }
}
