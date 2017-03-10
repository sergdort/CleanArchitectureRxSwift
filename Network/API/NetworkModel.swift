//
//  NetworkModel.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 10.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import Alamofire
import Domain
import RxAlamofire
import RxSwift
import JASON

private let ApiEndpoint = "https://jsonplaceholder.typicode.com"

public final class NetworkModel {

    func fetchPosts() -> Observable<[Post]> {
        return RxAlamofire
            .requestData(.get, ApiEndpoint + "/posts")
            .debug()
            .catchError { error in
                return Observable.never()
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, data) -> JSON in
                let json = JSON(data)
                return json
            })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ json -> [Post] in
                return []
            })
    }
}
