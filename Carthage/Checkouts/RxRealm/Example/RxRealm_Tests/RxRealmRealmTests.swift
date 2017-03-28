//
//  RxRealmRealmTests.swift
//  RxRealm
//
//  Created by Marin Todorov on 5/22/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import RxSwift
import RealmSwift
import RxRealm
import RxTest

class RxRealmRealmTests: XCTestCase {
    fileprivate func realmInMemory(_ name: String) -> Realm {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return try! Realm(configuration: conf)
    }
    
    func testRealmDidChangeNotifications() {
        let expectation1 = expectation(description: "Realm notification")
        
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        typealias loggedNotification = (Realm, Realm.Notification)
        let observer = scheduler.createObserver(loggedNotification.self)
        
        let realm$ = Observable<(Realm, Realm.Notification)>.from(realm: realm).shareReplay(1)
        realm$.scan(0, accumulator: {acc, _ in return acc+1})
            .filter { $0 == 2 }.map {_ in ()}.subscribe(onNext: expectation1.fulfill).addDisposableTo(bag)
        realm$
            .subscribe(observer).addDisposableTo(bag)
        
        //interact with Realm here
        delay(0.1) {
            try! realm.write {
                realm.add(Message("first"))
            }
        }
        delayInBackground(0.3) {[unowned self] in
            let realm = self.realmInMemory(#function)
            try! realm.write {
                realm.add(Message("second"))
            }
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 2)
            XCTAssertEqual(observer.events[0].value.element!.1, Realm.Notification.didChange)
            XCTAssertEqual(observer.events[1].value.element!.1, Realm.Notification.didChange)
        }
    }
    
    func testRealmRefreshRequiredNotifications() {
        let expectation1 = expectation(description: "Realm notification")
        
        let realm = realmInMemory(#function)
        realm.autorefresh = false
        
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        typealias loggedNotification = (Realm, Realm.Notification)
        let observer = scheduler.createObserver(loggedNotification.self)
        
        let realm$ = Observable<(Realm, Realm.Notification)>.from(realm: realm).shareReplay(1)
        realm$.scan(0, accumulator: {acc, _ in return acc+1})
            .filter { $0 == 1 }.map {_ in ()}.subscribe(onNext: expectation1.fulfill).addDisposableTo(bag)
        realm$
            .subscribe(observer).addDisposableTo(bag)
        
        //interact with Realm here from background
        delayInBackground(0.1) {[unowned self] in
            let realm = self.realmInMemory(#function)
            try! realm.write {
                realm.add(Message("second"))
            }
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 1)
            XCTAssertEqual(observer.events[0].value.element!.1, Realm.Notification.refreshRequired)
        }
    }

}
