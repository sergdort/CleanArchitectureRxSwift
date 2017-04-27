//
//  NetworkProvider.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 16.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain

public final class NetworkProvider {
    private let APIendPoint: String

    public init() {
        APIendPoint = "https://jsonplaceholder.typicode.com"
    }

    public func getAlbumsNetwork() -> AlbumsNetwork {
        let network = Network<Album>(APIendPoint)
        return AlbumsNetwork(network: network)
    }

    public func getCommentsNetwork() -> CommentsNetwork {
        let network = Network<Comment>(APIendPoint)
        return CommentsNetwork(network: network)
    }

    public func getPhotosNetwork() -> PhotosNetwork {
        let network = Network<Photo>(APIendPoint)
        return PhotosNetwork(network: network)
    }

    public func getPostsNetwork() -> PostsNetwork {
        let network = Network<Post>(APIendPoint)
        return PostsNetwork(network: network)
    }

    public func getTodosNetwork() -> TodosNetwork {
        let network = Network<Todo>(APIendPoint)
        return TodosNetwork(network: network)
    }

    public func getUsersNetwork() -> UsersNetwork {
        let network = Network<User>(APIendPoint)
        return UsersNetwork(network: network)
    }
}
