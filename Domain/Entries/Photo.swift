//
//  Photo.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation

public struct Photo: Codable {
    public let albumId: String
    public let thumbnailUrl: String
    public let title: String
    public let uid: String
    public let url: String

    public init(albumId: String,
                thumbnailUrl: String,
                title: String,
                uid: String,
                url: String) {
        self.albumId = albumId
        self.thumbnailUrl = thumbnailUrl
        self.title = title
        self.uid = uid
        self.url = url
    }
}

extension Photo: Equatable {
    public static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.title == rhs.title &&
            lhs.albumId == rhs.albumId &&
            lhs.url == rhs.url &&
            lhs.thumbnailUrl == rhs.thumbnailUrl
    }
}
