//
//  URLSession+RxAlamofire.swift
//  RxAlamofire
//
//  Created by Junior B. on 04/11/15.
//  Copyright © 2015 Bonto.ch. All rights reserved.
//

import Foundation

import Alamofire
import RxSwift
import RxCocoa

// MARK: NSURLSession extensions

extension Reactive where Base: URLSession {
    
    /**
     Creates an observable returning a decoded JSON object as `AnyObject`.
     
     - parameter method: Alamofire method object
     - parameter url: An object adopting `URLConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of a decoded JSON object as `AnyObject`
     */
    public func json(_ method: Alamofire.HTTPMethod,
        _ url: URLConvertible,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil) -> Observable<Any> {
            do {
                let request = try RxAlamofire.urlRequest(
                        method,
                        url,
                        parameters: parameters,
                        encoding: encoding,
                        headers: headers)
                return json(request: request)
            }
            catch let error {
                return Observable.error(error)
            }
    }

    /**
     Creates an observable returning a tuple of `(NSData!, NSURLResponse)`.
     
     - parameter method: Alamofire method object
     - parameter url: An object adopting `URLConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of a tuple containing data and the request
     */
    public func response(method: Alamofire.HTTPMethod,
        _ url: URLConvertible,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil) -> Observable<(HTTPURLResponse, Data)> {
            do {
                let request = try RxAlamofire.urlRequest(method,
                                                         url,
                                                         parameters: parameters,
                                                         encoding: encoding,
                                                         headers: headers)
                return response(request: request)
            }
            catch let error {
                return Observable.error(error)
            }
    }

    /**
     Creates an observable of response's content as `NSData`.
     
     - parameter method: Alamofire method object
     - parameter url: An object adopting `URLConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of a data
     */
    public func data(_ method: Alamofire.HTTPMethod,
        _ url: URLConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil) -> Observable<Data> {
            do {
                let request = try RxAlamofire.urlRequest(method,
                                                         url,
                                                         parameters: parameters,
                                                         encoding: encoding,
                                                         headers: headers)
                return data(request: request)
            }
            catch let error {
                return Observable.error(error)
            }
    }
}
