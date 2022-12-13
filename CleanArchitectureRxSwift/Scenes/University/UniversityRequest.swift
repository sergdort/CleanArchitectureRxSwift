//
//  UniversityRequest.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/13/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import Foundation
import Domain
class UniversityRequest: APIRequest {
    var method = RequestType.GET
    var path = "search"
    var parameters = [String: String]()

    init(name: String) {
        parameters["name"] = name
        print("name \(name)")
    }
}
