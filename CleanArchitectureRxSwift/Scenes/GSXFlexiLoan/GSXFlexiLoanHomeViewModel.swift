//
//  GSXFlexiLoanHomeViewModel.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/14/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxCocoa

class GSXHomeViewModel {
    
    private let useCase: PostsUseCase
    private let navigator: GSXHomeRouterProtocol
    
    init(useCase: PostsUseCase, navigator: GSXHomeRouterProtocol) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    
}

extension GSXHomeViewModel: ViewModelType {
    
    struct Input {
        let browerTrigger: Driver<Void>
        let trigger: Driver<Void>
    }
    
    struct Output {
        let flexiModel: Driver<FlexiLoanModel>
        let selectedBorrow: Driver<FlexiLoanModel>
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let flexiModel = input.trigger.flatMapLatest {
            return self.useCase.getFlexiLoan().trackError(errorTracker).trackActivity(activityIndicator).asDriverOnErrorJustComplete()
        }
        
        let objSelect = flexiModel.asDriver()
        
        let borrowSelected = input.browerTrigger.withLatestFrom(objSelect).do { obj in
            self.navigator.routerToInputBorrow(flex: obj)
        }
        return Output.init(flexiModel: flexiModel, selectedBorrow: borrowSelected)
    }

    
}
