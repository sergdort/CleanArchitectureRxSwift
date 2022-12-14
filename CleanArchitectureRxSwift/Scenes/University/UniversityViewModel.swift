//
//  UniversityViewModel.swift
//  CleanArchitectureRxSwift
//
//  Created by Kevin on 12/13/22.
//  Copyright © 2022 sergdort. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Domain

class UniversityViewModel: ViewModelType {
 
    struct Input {
        let trigger: Driver<Void>
        let searchText: Driver<String>
        let selection: Driver<IndexPath>
    }

    struct Output {
        let list: Driver<[UniversityModel]>
        let error: Driver<Error>
        let selected: Driver<UniversityModel>
    }
    
    private let useCase: PostsUseCase
    private let navigator: UniversityNavigator
    
    init(useCase: PostsUseCase, navigator: UniversityNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()

        
        let listUniversity = input.searchText.map { UniversityRequest(name: $0)}.flatMapLatest { request in
            return self.useCase.getList(apiRequest: request).trackActivity(activityIndicator).trackError(errorTracker).asDriverOnErrorJustComplete()
        }
        
        let selected = input.selection.withLatestFrom(listUniversity) {(indexPath, university) -> UniversityModel in
            return university[indexPath.row]
        }.do {self.navigator.routerToDetail(url: URL(string: $0.webPages?.first ?? "")!)}
        
//            .do(onNext: navigator.toPost)

        
        
        let errors = errorTracker.asDriver()
        return Output(list: listUniversity, error:errors, selected: selected)
    }
}

