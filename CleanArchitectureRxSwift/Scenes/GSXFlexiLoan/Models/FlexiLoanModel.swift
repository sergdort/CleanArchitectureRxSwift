//
//  FlexiLoanModel.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/14/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import Foundation

public struct FlexiLoanModel: Codable {
    public var availableLOC: GSXValue?
    public var offeredInterestRate: Double?
    public var offeredEIR: Double?
    public var min: GSXValue?
    public var max: GSXValue?
    
    public init(availableLOC: GSXValue? = nil, offeredInterestRate: Double? = nil, offeredEIR: Double? = nil, min: GSXValue? = nil, max: GSXValue? = nil) {
        self.availableLOC = availableLOC
        self.offeredInterestRate = offeredInterestRate
        self.offeredEIR = offeredEIR
        self.min = min
        self.max = max
    }

}

public struct GSXValue: Codable {
    public var currencyCode: String
    public var val: Double
    
   public init(currencyCode: String, val: Double) {
        self.currencyCode = currencyCode
        self.val = val
    }
}



//{
//  "availableLOC": {
//    "currencyCode": "SGD",
//    "val": 10000
//  },
//  "offeredInterestRate": 3.00,
//  "offeredEIR": 5.45,
//  "min": {
//    "currencyCode": "SGD",
//    "val": 200
//  },
//  "max": {
//    "currencyCode": "SGD",
//    "val": 10000
//  }
//}
