//
//  MockPostsUseCase.swift
//  CleanArchitectureRxSwiftTests
//
//  Created by kapilrathore-mbp on 18/10/19.
//  Copyright © 2019 sergdort. All rights reserved.
//

import Domain
import RxSwift

class MockPostsUseCase: Domain.PostsUseCase {
    var postsResponse: Observable<[Post]>!
    func posts() -> Observable<[Post]> {
        return postsResponse
    }
    
    var saveResponse: Observable<Void>!
    func save(post: Post) -> Observable<Void> {
        return saveResponse
    }
    
    var deleteResponse: Observable<Void>!
    func delete(post: Post) -> Observable<Void> {
        return deleteResponse
    }
}
