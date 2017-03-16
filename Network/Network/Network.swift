//
//  Network.swift
//  CleanArchitectureRxSwift
//
//  Created by Andrey Yastrebov on 16.03.17.
//  Copyright © 2017 sergdort. All rights reserved.
//

import Foundation
import Alamofire
import Domain
import RxAlamofire
import RxSwift
import ObjectMapper

public final class Network<T: BaseMappable> {

    private let endPoint: String

    required public init(_ endPoint: String) {
        self.endPoint = endPoint
    }

    func getItems(_ path: String) -> Observable<[T]> {
        let absolutePath = endPoint.appendingFormat("/%s", path)
        return RxAlamofire
            .json(.get, absolutePath)
            .debug()
            .map({ json -> [T] in
                return Mapper<T>().mapArray(JSONObject: json)!
            })
    }

    func getItem(_ path: String, itemId: Int) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s/%d", path, itemId)
        return RxAlamofire
            .request(.get, absolutePath)
            .debug()
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }

    func postItem(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s", path)
        return RxAlamofire
            .request(.post, absolutePath, parameters: parameters)
            .debug()
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }

    func updateItem(_ path: String, itemId: Int, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s/%d", path, itemId)
        return RxAlamofire
            .request(.put, absolutePath, parameters: parameters)
            .debug()
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }

    func deleteItem(_ path: String, itemId: Int) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s/%d", path, itemId)
        return RxAlamofire
            .request(.delete, absolutePath)
            .debug()
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }
}
