//
// Created by sergdort on 19/02/2017.
// Copyright (c) 2017 sergdort. All rights reserved.
//

import Domain
import Foundation
import RxCocoa
import RxSwift

final class CreatePostViewModel: ViewModelType {
    private let createPostUseCase: PostsUseCase
    private let navigator: CreatePostNavigator

    init(createPostUseCase: PostsUseCase, navigator: CreatePostNavigator) {
        self.createPostUseCase = createPostUseCase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let titleAndDetails = Driver.combineLatest(input.title, input.details)
        let activityIndicator = ActivityIndicator()

        let canSave = Driver.combineLatest(titleAndDetails, activityIndicator.asDriver()) {
            !$0.0.isEmpty && !$0.1.isEmpty && !$1
        }

        let save = input.saveTrigger.withLatestFrom(titleAndDetails)
            .map { title, content in
                Post(body: content, title: title)
            }
            .flatMapLatest { [unowned self] in
                self.createPostUseCase.save(post: $0)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let dismiss = Driver.of(save, input.cancelTrigger)
            .merge()
            .do(onNext: navigator.toPosts)

        return Output(dismiss: dismiss, saveEnabled: canSave)
    }
}

extension CreatePostViewModel {
    struct Input {
        let cancelTrigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let title: Driver<String>
        let details: Driver<String>
    }

    struct Output {
        let dismiss: Driver<Void>
        let saveEnabled: Driver<Bool>
    }
}
