//
//  RxRealmCollectionsTests.swift
//  RxRealm
//
//  Created by Marin Todorov on 4/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import RxSwift
import RealmSwift
import RxRealm
import RxTest

class RxRealmResultsTests: XCTestCase {
    
    fileprivate func realmInMemory(_ name: String) -> Realm {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return try! Realm(configuration: conf)
    }
    
    fileprivate func clearRealm(_ realm: Realm) {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func testResultsType() {
        let expectation1 = expectation(description: "Results<Message> first")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Results<Message>.self)
        
        let messages$ = Observable.collection(from: realm.objects(Message.self)).shareReplay(1)
        messages$.scan(0, accumulator: {acc, _ in return acc+1})
            .filter { $0 == 4 }.map {_ in ()}.subscribe(onNext: expectation1.fulfill).addDisposableTo(bag)
        messages$
            .subscribe(observer).addDisposableTo(bag)
        
        //interact with Realm here
        delay(0.1) {
            try! realm.write {
                realm.add(Message("first"))
            }
        }
        delay(0.2) {
            try! realm.write {
                realm.delete(realm.objects(Message.self).first!)
            }
        }
        delay(0.3) {
            try! realm.write {
                realm.add(Message("second"))
            }
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.5) {error in
            //do tests here
            
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 4)
            let results = observer.events.last!.value.element!
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first!.text, "second")
        }
    }
    
    func testResultsTypeChangeset() {
        let expectation1 = expectation(description: "Results<Message> first")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        
        let messages$ = Observable.changeset(from: realm.objects(Message.self)).shareReplay(1)
        messages$.scan(0, accumulator: {acc, _ in return acc+1})
            .filter { $0 == 3 }.map {_ in ()}.subscribe(onNext: expectation1.fulfill).addDisposableTo(bag)
        messages$
            .map {results, changes in
                if let changes = changes {
                    return "i:\(changes.inserted) d:\(changes.deleted) u:\(changes.updated)"
                } else {
                    return "initial"
                }
            }
            .subscribe(observer).addDisposableTo(bag)
        
        //interact with Realm here
        delay(0.1) {
            try! realm.write {
                realm.add(Message("first"))
            }
        }
        delay(0.2) {
            try! realm.write {
                realm.delete(realm.objects(Message.self).first!)
            }
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.5) {error in
            //do tests here
            
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 3)
            XCTAssertEqual(observer.events[0].value.element!, "initial")
            XCTAssertEqual(observer.events[1].value.element!, "i:[0] d:[] u:[]")
            XCTAssertEqual(observer.events[2].value.element!, "i:[] d:[0] u:[]")
        }
    }

    func testResultsEmitsCollectionSynchronously() {
        let realm = realmInMemory(#function)
        let bag = DisposeBag()

        // collection
        let scheduler = TestScheduler(initialClock: 0)
        let observer1 = scheduler.createObserver(Results<Message>.self)

        Observable.collection(from: realm.objects(Message.self), synchronousStart: true)
            .subscribe(observer1)
            .addDisposableTo(bag)

        XCTAssertEqual(observer1.events.count, 1)
        XCTAssertEqual(observer1.events[0].value.element!.count, 0)

    }

    func testResultsEmitsChangesetSynchronously() {
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        // changeset
        let observer2 = scheduler.createObserver(Int.self)

        Observable.changeset(from: realm.objects(Message.self), synchronousStart: true)
            .map { $0.0.count }
            .subscribe(observer2)
            .addDisposableTo(bag)

        XCTAssertEqual(observer2.events.count, 1)
        XCTAssertEqual(observer2.events[0].value.element!, 0)
    }

    func testResultsEmitsCollectionAsynchronously() {
        let expectation1 = expectation(description: "Async collection emit")

        let realm = realmInMemory(#function)
        let bag = DisposeBag()

        let scheduler = TestScheduler(initialClock: 0)

        // test collection

        let observer = scheduler.createObserver(Results<Message>.self)

        let messages$ = Observable.collection(from: realm.objects(Message.self), synchronousStart: false)
            .share()

        messages$
            .subscribe(observer)
            .addDisposableTo(bag)

        messages$
            .subscribe(onNext: {_ in
                expectation1.fulfill()
            })
            .addDisposableTo(bag)

        XCTAssertEqual(observer.events.count, 0)

        waitForExpectations(timeout: 5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 1)
            XCTAssertEqual(observer.events[0].value.element!.count, 0)
        }
    }

    func testResultsEmitsChangesetAsynchronously() {
        // test changeset
        let expectation2 = expectation(description: "Async changeset emit")

        let realm = realmInMemory(#function)
        let bag = DisposeBag()

        let scheduler = TestScheduler(initialClock: 0)

        let observer2 = scheduler.createObserver(Int.self)

        let messages2$ = Observable.changeset(from: realm.objects(Message.self), synchronousStart: false)
            .share()

        messages2$
            .map { $0.0.count }
            .subscribe(observer2)
            .addDisposableTo(bag)

        messages2$
            .subscribe(onNext: {_ in
                expectation2.fulfill()
            })
            .addDisposableTo(bag)

        XCTAssertEqual(observer2.events.count, 0)

        waitForExpectations(timeout: 5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer2.events.count, 1)
            XCTAssertEqual(observer2.events[0].value.element!, 0)
        }
        

    }

}
