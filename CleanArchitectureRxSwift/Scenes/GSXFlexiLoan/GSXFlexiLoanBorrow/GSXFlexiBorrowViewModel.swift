//
//  GSXFlexiBorrowViewModel.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/14/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxCocoa

class GSXFlexBorrowViewModel {
    
    init() {
        
    }
}

extension GSXFlexBorrowViewModel: ViewModelType {
    
    func transform(input: Input) -> Output {
        
        let condition = input.amount.map { text -> Bool in
            if text.isEmpty {
                return true
            } else {
                return Double(text) ?? 0.0 > input.min && Double(text) ?? 0.0 < input.max
            }
        }
        
        return Output.init(valid: condition)
    }
    
    struct Input {
        let amount: Driver<String>
        var min: Double
        var max: Double
    }
    
    struct Output {
        let valid: Driver<Bool>
    }
    
}
