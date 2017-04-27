//
//  Todo.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation

public struct Todo {
    public let completed: Bool
    public let title: String
    public let uid: String
    public let userId: String

    public init(completed: Bool,
                title: String,
                uid: String,
                userId: String) {
        self.completed = completed
        self.title = title
        self.uid = uid
        self.userId = userId
    }
}

extension Todo: Equatable {
    public static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.title == rhs.title &&
            lhs.completed == rhs.completed &&
            lhs.userId == rhs.userId
    }
}
