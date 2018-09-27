//
//  Album.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation

public struct Album: Codable {
    public let title: String
    public let uid: String
    public let userId: String

    public init(title: String,
                uid: String,
                userId: String) {
        self.title = title
        self.uid = uid
        self.userId = userId
    }
}

extension Album: Equatable {
    public static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.title == rhs.title &&
            lhs.userId == rhs.userId
    }
}
