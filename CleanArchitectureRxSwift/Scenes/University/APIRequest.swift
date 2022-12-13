//
//  APIRequest.swift
//  MovieChallenge
//
//  Created by Kevin on 12/9/22.
//

import Foundation

public enum RequestType: String {
    case GET, POST
}

public protocol APIRequest {
    var method: RequestType { get }
    var path: String { get }
    var parameters: [String : String] { get }
}

extension APIRequest {
public  func request(with baseURL: URL) -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }

        components.queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }

        guard let url = components.url else {
            fatalError("Could not get url")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
