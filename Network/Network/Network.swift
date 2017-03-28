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
    private let scheduler: ConcurrentDispatchQueueScheduler

    required public init(_ endPoint: String) {
        self.endPoint = endPoint
        self.scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1))
    }

    func getItems(_ path: String) -> Observable<[T]> {
        let absolutePath = endPoint.appendingFormat("/%s", path)
        return RxAlamofire
            .json(.get, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ json -> [T] in
                return Mapper<T>().mapArray(JSONObject: json)!
            })
    }

    func getItem(_ path: String, itemId: Int) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s/%d", path, itemId)
        return RxAlamofire
            .request(.get, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }

    func postItem(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s", path)
        return RxAlamofire
            .request(.post, absolutePath, parameters: parameters)
            .debug()
            .observeOn(scheduler)
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }

    func updateItem(_ path: String, itemId: Int, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s/%d", path, itemId)
        return RxAlamofire
            .request(.put, absolutePath, parameters: parameters)
            .debug()
            .observeOn(scheduler)
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }

    func deleteItem(_ path: String, itemId: Int) -> Observable<T> {
        let absolutePath = endPoint.appendingFormat("/%s/%d", path, itemId)
        return RxAlamofire
            .request(.delete, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ json -> T in
                return Mapper<T>().map(JSONObject: json)!
            })
    }
}