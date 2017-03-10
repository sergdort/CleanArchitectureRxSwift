//
//  Album.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation

public struct Album {
    public let title: String
    public let uid: Int
    public let userId: Int

    public init(title: String,
                uid: Int,
                userId: Int) {
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
