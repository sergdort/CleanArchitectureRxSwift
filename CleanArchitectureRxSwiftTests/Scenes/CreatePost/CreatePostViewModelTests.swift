//
//  CreatePostViewModelTests.swift
//  CleanArchitectureRxSwiftTests
//
//  Created by kapilrathore-mbp on 18/10/19.
//  Copyright © 2019 sergdort. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
@testable import CleanArchitectureRxSwift
import Domain

class CreatePostViewModelTests: XCTestCase {
    var usecase: MockPostsUseCase!
    var navigator: MockCreatePostNavigator!
    var viewModel: CreatePostViewModel!
    var disposeBag: DisposeBag!
    
    // ViewModel Input Subjects
    var cancelTriggerInput: PublishSubject<Void>!
    var saveTriggerInput: PublishSubject<Void>!
    var titleInput: PublishSubject<String>!
    var detailsInput: PublishSubject<String>!
    
    // ViewModel Output Observers
    var dismissOutput: TestableObserver<Void>!
    var saveEnabledOutput: TestableObserver<Bool>!

    override func setUp() {
        usecase = MockPostsUseCase()
        navigator = MockCreatePostNavigator()
        viewModel = CreatePostViewModel(createPostUseCase: usecase, navigator: navigator)
        disposeBag = DisposeBag()
        
        cancelTriggerInput = PublishSubject<Void>()
        saveTriggerInput = PublishSubject<Void>()
        titleInput = PublishSubject<String>()
        detailsInput = PublishSubject<String>()
        
        let testScheduler = TestScheduler(initialClock: 0)
        dismissOutput = testScheduler.createObserver(Void.self)
        saveEnabledOutput = testScheduler.createObserver(Bool.self)
        
        let viewModelInput = CreatePostViewModel.Input(
            cancelTrigger: cancelTriggerInput.asDriverOnErrorJustComplete(),
            saveTrigger: saveTriggerInput.asDriverOnErrorJustComplete(),
            title: titleInput.asDriverOnErrorJustComplete(),
            details: detailsInput.asDriverOnErrorJustComplete()
        )
        
        let viewModelOutput = viewModel.transform(input: viewModelInput)
        
        viewModelOutput.dismiss.drive(dismissOutput).disposed(by: disposeBag)
        viewModelOutput.saveEnabled.drive(saveEnabledOutput).disposed(by: disposeBag)
    }

    override func tearDown() {
        usecase = nil
        navigator = nil
        viewModel = nil
        disposeBag = nil
    }
    
    func test_transform_onlyTitleInput() {
        // When
        titleInput.onNext("Some title")
        
        // Then
        XCTAssertEqual(saveEnabledOutput.events.count, 0)
        XCTAssertEqual(dismissOutput.events.count, 0)
    }
    
    func test_transform_onlyDetailsInput() {
        // When
        detailsInput.onNext("Some details")
        
        // Then
        XCTAssertEqual(saveEnabledOutput.events.count, 0)
        XCTAssertEqual(dismissOutput.events.count, 0)
    }
    
    func test_transform_titleAndDetailsInput() {
        // When
        titleInput.onNext("Some title")
        detailsInput.onNext("Some details")
        
        // Then
        XCTAssertEqual(saveEnabledOutput.events, [.next(0, true)])
        XCTAssertEqual(dismissOutput.events.count, 0)
    }
    
    func test_transform_SaveInput() {
        // Mocking
        usecase.saveResponse = Observable.just(())
        
        // When
        titleInput.onNext("Some title")
        detailsInput.onNext("Some details")
        saveTriggerInput.onNext(())
        
        // Then
        XCTAssertEqual(saveEnabledOutput.events, [.next(0, true), .next(0, false), .next(0, true)])
        XCTAssertEqual(dismissOutput.events.count, 1)
    }
    // For checking error on save in the above test
    // usecase.saveResponse = Observable.error(NSError()) => will give same output
    
    func test_transform_CancelInput() {
        // When
        cancelTriggerInput.onNext(())
        
        // Then
        XCTAssertEqual(saveEnabledOutput.events.count, 0)
        XCTAssertEqual(dismissOutput.events.count, 1)
    }
}

class MockCreatePostNavigator: CreatePostNavigator {
    func toPosts() { }
}
