//
//  PostsNetwork.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Domain
import RxSwift

public final class PostsNetwork {
    private let network: Network<Post>

    init(network: Network<Post>) {
        self.network = network
    }

    public func fetchPosts() -> Observable<[Post]> {
        return network.getItems("posts")
    }

    public func fetchPost(postId: String) -> Observable<Post> {
        return network.getItem("posts", itemId: postId)
    }

    public func createPost(post: Post) -> Observable<Post> {
        return network.postItem("posts", parameters: post.toJSON())
    }

    public func deletePost(postId: String) -> Observable<Post> {
        return network.deleteItem("posts", itemId: postId)
    }
    
    public func getList(apiRequest: APIRequest) -> Observable<[UniversityModel]> {
        let baseURL = URL(string: "http://universities.hipolabs.com/")!
        let request = apiRequest.request(with: baseURL)
        return network.send(urlRequest: request)
    }
    
    public func getFlexiloan() -> Observable<FlexiLoanModel> {
        let baseURL = URL(string: "https://codedeman.github.io/ssd_api/gsx-flexiloan.json")!
        let request  = URLRequest(url: baseURL)
        return network.send(urlRequest: request)
    }
}
