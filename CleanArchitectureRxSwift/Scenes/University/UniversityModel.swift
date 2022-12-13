//
//  UniversityModel.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/13/22.
//  Copyright © 2022 sergdort. All rights reserved.
//


import Foundation

public struct UniversityModel: Codable {
    
    public let name: String
    public let webPages: [String]?
    public let country: String

    private enum CodingKeys: String, CodingKey {
        case name
        case webPages = "web_pages"
        case country
    }

    var description: String {
        get {
            if let webPage = webPages?.first {
                return "\(country) • \(webPage)"
            } else {
                return country
            }
        }
    }
}
