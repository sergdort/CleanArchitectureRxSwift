//
//  Todo.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation

public struct Todo: Decodable {
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

    private enum CodingKeys: String, CodingKey {
        case completed
        case title
        case uid
        case userId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        completed = try container.decode(Bool.self, forKey: .completed)
        title = try container.decode(String.self, forKey: .title)

        if let userId = try container.decodeIfPresent(Int.self, forKey: .userId) {
            self.userId = "\(userId)"
        } else {
            userId = try container.decode(String.self, forKey: .userId)
        }

        if let uid = try container.decodeIfPresent(Int.self, forKey: .uid) {
            self.uid = "\(uid)"
        } else {
            uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        }
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
