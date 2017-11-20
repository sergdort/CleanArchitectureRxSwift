//
//  CommentsNetwork.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 16.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import RxSwift

public final class CommentsNetwork {
    private let network: Network<Comment>

    init(network: Network<Comment>) {
        self.network = network
    }

    public func fetchComments() -> Observable<[Comment]> {
        return network.getItems("comments")
    }

    public func fetchComment(commentId: String) -> Observable<Comment> {
        return network.getItem("comments", itemId: commentId)
    }
}
