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
import ObjectMapper

private let ApiEndpoint = "https://jsonplaceholder.typicode.com"

public final class NetworkModel {

    func fetchPosts() -> Observable<[Post]> {
        return RxAlamofire
            .json(.get, ApiEndpoint + "/posts")
            .debug()
            .catchError { error in
                return Observable.never()
            }
            .flatMap({ json -> Observable<[Post]> in
                Observable.just(try Mapper<Post>().mapArray(JSONArray: json as! [[String : Any]]))
            })
    }

//    func fetchUsers() -> Observable<[User]> {
//        return RxAlamofire
//            .request(.get, ApiEndpoint + "/users")
//            .debug()
//            .catchError { error in
//                return Observable.never()
//            }
//            .flatMap({ (request: DataRequest) -> Observable<DataResponse<[User]>> in
//                return request.responseArray()
//            })
//            .map({ response -> [User] in
//                guard let users = response.result.value else {
//                    return []
//                }
//
//                return users
//            })
//    }
}
