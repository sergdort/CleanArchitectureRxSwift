//
//  NetworkProvider.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 16.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain

final class NetworkProvider {
    private let apiEndpoint: String

    public init() {
        apiEndpoint = "https://jsonplaceholder.typicode.com"
    }

    public func makeAlbumsNetwork() -> AlbumsNetwork {
        let network = MyNetwork<Album>(apiEndpoint)
        return AlbumsNetwork(network: network)
    }

    public func makeCommentsNetwork() -> CommentsNetwork {
        let network = MyNetwork<Comment>(apiEndpoint)
        return CommentsNetwork(network: network)
    }

    public func makePhotosNetwork() -> PhotosNetwork {
        let network = MyNetwork<Photo>(apiEndpoint)
        return PhotosNetwork(network: network)
    }

    public func makePostsNetwork() -> PostsNetwork {
        let network = MyNetwork<Post>(apiEndpoint)
        return PostsNetwork(network: network)
    }

    public func makeTodosNetwork() -> TodosNetwork {
        let network = MyNetwork<Todo>(apiEndpoint)
        return TodosNetwork(network: network)
    }

    public func makeUsersNetwork() -> UsersNetwork {
        let network = MyNetwork<User>(apiEndpoint)
        return UsersNetwork(network: network)
    }
}
