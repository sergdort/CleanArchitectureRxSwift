import Foundation

public struct Post {
    public let uid: String
    public let userId: String
    public let title: String
    public let body: String
//    public let createDate: Date
//    public let updateDate: Date
//    public let title: String
//    public let content: String
//    public let media: Media?
//    public let location: Location?

//    public init(uid: String,
//                createDate: Date,
//                updateDate: Date,
//                title: String,
//                content: String,
//                media: Media? = nil,
//                location: Location? = nil) {
//        self.uid = uid
//        self.createDate = createDate
//        self.updateDate = updateDate
//        self.title = title
//        self.content = content
//        self.media = media
//        self.location = location
//    }
    public init(uid: String,
                userId: String,
                title: String,
                body: String) {
        self.uid = uid
        self.userId = userId
        self.body = body
        self.title = title
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
