//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//

import XCTest

import RxSwift
import RealmSwift
import RxRealm
import RxTest

func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func delayInBackground(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


class RxRealm_Tests: XCTestCase {
    
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
    
    fileprivate func addMessage(_ realm: Realm, text: String) {
        try! realm.write {
            realm.add(Message(text))
        }
    }
    
    func testEmittedResultsValues() {
        let expectation1 = expectation(description: "Results<Message>")

        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Results<Message>.self)
        
        let messages$ = Observable.collection(from: realm.objects(Message.self)).shareReplay(1)
        messages$.subscribe(onNext: {
            if $0.count == 2 {
                expectation1.fulfill()
            }
        }).addDisposableTo(bag)
        
        messages$.subscribe(observer).addDisposableTo(bag)

        addMessage(realm, text: "first(Results)")
        
        delay(0.1) {
            self.addMessage(realm, text: "second(Results)")
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.5) {error in
            XCTAssertNil(error, "Error: \(error?.localizedDescription)")
            XCTAssertTrue(observer.events.count > 0)
            let results = observer.events.last!.value.element!
            XCTAssertTrue(results.first! == Message("first(Results)"))
            XCTAssertTrue(results.last! == Message("second(Results)"))
        }
    }
    
    func testEmittedArrayValues() {
        let expectation1 = expectation(description: "Array<Message> expectation")

        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>.self)

        let messages$ = Observable.array(from: realm.objects(Message.self)).shareReplay(1)
        messages$.subscribe(onNext: {
            if $0.count == 2 {
                expectation1.fulfill()
            }
        }).addDisposableTo(bag)
        
        messages$.subscribe(observer).addDisposableTo(bag)
        
        addMessage(realm, text: "first(Array)")

        delay(0.1) {
            self.addMessage(realm, text: "second(Array)")
        }

        scheduler.start()
        
        waitForExpectations(timeout: 0.5) {error in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            XCTAssertTrue(observer.events.count > 0)
            XCTAssertTrue(observer.events[observer.events.count-2].value.element!.equalTo([Message("first(Array)")]))
            XCTAssertTrue(observer.events[observer.events.count-1].value.element!.equalTo([Message("first(Array)"), Message("second(Array)")]))
        }
    }
    
    func testEmittedChangeset() {
        let expectation1 = expectation(description: "did emit all changeset values")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)

        //initial data
        addMessage(realm, text: "first(Changeset)")

        let messages$ = Observable.changeset(from: realm.objects(Message.self)).shareReplay(1)
        messages$.scan(0) { count, _ in
            return count+1
        }
        .filter {$0 == 3}
        .subscribe(onNext: {_ in expectation1.fulfill() })
        .addDisposableTo(bag)
        
        messages$
            .map {result, changes in
                if let changes = changes {
                    return "count:\(result.count) inserted:\(changes.inserted) deleted:\(changes.deleted) updated:\(changes.updated)"
                } else {
                    return "count:\(result.count)"
                }
            }
            .subscribe(observer).addDisposableTo(bag)

        //insert
        delay(0.25) {
            self.addMessage(realm, text: "second(Changeset)")
        }
        //update
        delay(0.5) {
            try! realm.write {
                realm.delete(realm.objects(Message.self).filter("text='first(Changeset)'").first!)
                realm.objects(Message.self).filter("text='second(Changeset)'").first!.text = "third(Changeset)"
            }
        }
        //coalesced
        delay(0.7) {
            self.addMessage(realm, text: "first(Changeset)")
        }
        delay(0.7) {
            try! realm.write {
                realm.delete(realm.objects(Message.self).filter("text='first(Changeset)'").first!)
            }
        }
        
        waitForExpectations(timeout: 0.75) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 3)
            XCTAssertEqual(observer.events[0].value.element!, "count:1")
            XCTAssertEqual(observer.events[1].value.element!, "count:2 inserted:[1] deleted:[] updated:[]")
            XCTAssertEqual(observer.events[2].value.element!, "count:1 inserted:[] deleted:[0] updated:[1]")
        }
    }

    func testEmittedArrayChangeset() {
        let expectation1 = expectation(description: "did emit all array changeset values")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        
        //initial data
        addMessage(realm, text: "first(ArrayChangeset)")
        
        let messages$ = Observable.changeset(from: realm.objects(Message.self)).shareReplay(1)
        messages$.scan(0) { count, _ in
            return count+1
            }
            .filter {$0 == 3}
            .subscribe(onNext: {_ in expectation1.fulfill() })
            .addDisposableTo(bag)
        
        messages$
            .map {result, changes in
                if let changes = changes {
                    return "count:\(result.count) inserted:\(changes.inserted) deleted:\(changes.deleted) updated:\(changes.updated)"
                } else {
                    return "count:\(result.count)"
                }
            }
            .subscribe(observer).addDisposableTo(bag)
        
        //insert
        delay(0.25) {
            self.addMessage(realm, text: "second(ArrayChangeset)")
        }
        //update
        delay(0.5) {
            try! realm.write {
                realm.delete(realm.objects(Message.self).filter("text='first(ArrayChangeset)'").first!)
                realm.objects(Message.self).filter("text='second(ArrayChangeset)'").first!.text = "third(ArrayChangeset)"
            }
        }
        //coalesced
        delay(0.7) {
            self.addMessage(realm, text: "first(ArrayChangeset)")
        }
        delay(0.7) {
            try! realm.write {
                realm.delete(realm.objects(Message.self).filter("text='first(ArrayChangeset)'").first!)
            }
        }
        
        waitForExpectations(timeout: 0.75) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 3)
            XCTAssertEqual(observer.events[0].value.element!, "count:1")
            XCTAssertEqual(observer.events[1].value.element!, "count:2 inserted:[1] deleted:[] updated:[]")
            XCTAssertEqual(observer.events[2].value.element!, "count:1 inserted:[] deleted:[0] updated:[1]")
        }
    }
    
}
