import Foundation

public struct Post {
    public let uid: String
    public let createDate: Date
    public let updateDate: Date
    public let title: String
    public let content: String
    public let media: Media?
    public let location: Location?
    
    public init(uid: String,
                createDate: Date,
                updateDate: Date,
                title: String,
                content: String,
                media: Media? = nil,
                location: Location? = nil) {
        self.uid = uid
        self.createDate = createDate
        self.updateDate = updateDate
        self.title = title
        self.content = content
        self.media = media
        self.location = location
    }
}

extension Post: Equatable {
    public static func == (lhs: Post, rhs: Post) -> Bool {
            return lhs.uid == rhs.uid &&
                lhs.createDate == rhs.createDate &&
                lhs.updateDate == rhs.updateDate && 
                lhs.title == rhs.title && 
                lhs.content == rhs.content && 
                lhs.media == rhs.media && 
                lhs.location == rhs.location
    }
}
