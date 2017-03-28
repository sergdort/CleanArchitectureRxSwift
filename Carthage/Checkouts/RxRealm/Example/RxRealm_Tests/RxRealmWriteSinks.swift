//
//  RxRealmWriteSinks.swift
//  RxRealm
//
//  Created by Marin Todorov on 6/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import RxSwift
import RealmSwift
import RxRealm
import RxTest

class RxRealmWriteSinks: XCTestCase {
    fileprivate func realmInMemoryConfiguration(_ name: String) -> Realm.Configuration {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return conf
    }
    
    fileprivate func realmInMemory(_ name: String) -> Realm {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return try! Realm(configuration: conf)
    }

    func testRxAddObject() {
        let expectation = self.expectation(description: "Message1")
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        let events = [
            next(0, Message("1")),
            completed(0)
        ]
        
        let rx_add: AnyObserver<Message> = realm.rx.add()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        let messages$ = Observable.array(from: realm.objects(Message.self)).shareReplay(1)

        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$
            .subscribe(onNext: { messages in
                if messages.count == 1 {
                    expectation.fulfill()
                }
            })
            .addDisposableTo(bag)
        
        observable
            .subscribe(rx_add)
            .addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectations(timeout: 1, handler: {error in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            XCTAssertTrue(observer.events.count > 0)
            XCTAssertEqual(observer.events.last!.time, 0)
            XCTAssertTrue(observer.events.last!.value.element!.equalTo([Message("1")]))
        })
    }
    
    func testRxAddObjects() {
        let expectation = self.expectation(description: "Message1")
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        let events = [
            next(0, [Message("1"), Message("2")]),
            completed(0)
        ]
        
        let rx_add: AnyObserver<[Message]> = realm.rx.add()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        let messages$ = Observable.array(from: realm.objects(Message.self)).shareReplay(1)
        
        observable.subscribe(rx_add)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribe(onNext: {
            if $0.count == 2 {
                expectation.fulfill()
            }
        }).addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.1, handler: {error in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            XCTAssertTrue(observer.events.count > 0)
            XCTAssertEqual(observer.events.last!.time, 0)
            XCTAssertTrue(observer.events.last!.value.element!.equalTo([Message("1"), Message("2")]))
        })
    }
    
    func testRxAddUpdateObjects() {
        let expectation = self.expectation(description: "Message1")
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        let events = [
            next(0, [UniqueObject(1), UniqueObject(2)]),
            next(1, [UniqueObject(1), UniqueObject(3)]),
            completed(2)
        ]
        
        let rx_add: AnyObserver<[UniqueObject]> = realm.rx.add(update: true)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<UniqueObject>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        let messages$ = Observable.array(from: realm.objects(UniqueObject.self)).shareReplay(1)
        
        observable.subscribe(rx_add)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribe(onNext: {
            switch $0.count {
            case 3:
                expectation.fulfill()
            default:
                break
            }
        }).addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectations(timeout: 5, handler: {error in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            //check that UniqueObject with id == 1 was overwritten
            XCTAssertTrue(observer.events.last!.value.element!.count == 3)
            XCTAssertTrue(observer.events.last!.value.element![0] == UniqueObject(1))
            XCTAssertTrue(observer.events.last!.value.element![1] == UniqueObject(2))
            XCTAssertTrue(observer.events.last!.value.element![2] == UniqueObject(3))
        })
        
    }

    
    func testRxDeleteItem() {
        let expectation = self.expectation(description: "Message1")
        let realm = realmInMemory(#function)
        let element = Message("1")
        let scheduler = TestScheduler(initialClock: 0)
        let messages$ = Observable.array(from: realm.objects(Message.self)).shareReplay(1)
        let rx_delete: AnyObserver<Message> = Realm.rx.delete()
        
        try! realm.write {
            realm.add(element)
        }
        let bag = DisposeBag()
        let events = [
            next(0, element),
            completed(0)
        ]
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        
        observable.subscribe(rx_delete)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribe(onNext: {
            switch $0.count {
            case 0:
                expectation.fulfill()
            default:
                break
            }
        }).addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.1, handler: {error in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            XCTAssertTrue(observer.events.count > 0)
            XCTAssertEqual(observer.events.last!.time, 0)
            XCTAssertEqual(observer.events.last!.value.element!, [Message]())
        })
    }
    
    func testRxDeleteItems() {
        let expectation = self.expectation(description: "Message1")
        let realm = realmInMemory(#function)
        let elements = [Message("1"), Message("1")]
        let scheduler = TestScheduler(initialClock: 0)
        let messages$ = Observable.array(from: realm.objects(Message.self)).shareReplay(1)
        let rx_delete: AnyObserver<[Message]> = Realm.rx.delete()
        
        try! realm.write {
            realm.add(elements)
        }
        let bag = DisposeBag()
        let events = [
            next(0, elements),
            completed(0)
        ]
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        
        observable.subscribe(rx_delete)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribe(onNext: {
            switch $0.count {
            case 0:
                expectation.fulfill()
            default:
                break
            }
        }).addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectations(timeout: 0.1, handler: {error in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            XCTAssertTrue(observer.events.count > 0)
            XCTAssertEqual(observer.events.last!.time, 0)
            XCTAssertTrue(observer.events.last!.value.element!.isEmpty)
        })
    }
    
    func testRxAddObjectsInBg() {
        let expectation = self.expectation(description: "All writes completed")
        
        let realm = realmInMemory(#function)
        var conf  = Realm.Configuration()
        conf.inMemoryIdentifier = #function
        
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Results<Message>.self)
        
        let messages$ = Observable.collection(from: realm.objects(Message.self)).shareReplay(1)
        
        messages$
            .subscribe(observer).addDisposableTo(bag)

        messages$
            .filter {$0.count == 8}
            .subscribe(onNext: {_ in expectation.fulfill() })
            .addDisposableTo(bag)
        
        scheduler.start()
        
        // subscribe/write on current thread
        Observable.from([Message("1")])
            .subscribe( realm.rx.add() )
            .addDisposableTo(bag)
        
        delayInBackground(0.1, closure: {
            // subscribe/write on background thread
            let realm = try! Realm(configuration: conf)
            Observable.from([Message("2")])
                .subscribe(realm.rx.add() )
                .addDisposableTo(bag)
        })
        
        // subscribe on current/write on main
        Observable.from([Message("3")])
            .observeOn(MainScheduler.instance)
            .subscribe( Realm.rx.add(configuration: conf) )
            .addDisposableTo(bag)

        Observable.from([Message("4")])
            .observeOn( ConcurrentDispatchQueueScheduler(
                queue: DispatchQueue.global(qos: .background)))
            .subscribe( Realm.rx.add(configuration: conf) )
            .addDisposableTo(bag)

        // subscribe on current/write on background
        Observable.from([[Message("5"), Message("6")]])
            .observeOn( ConcurrentDispatchQueueScheduler(
                queue: DispatchQueue.global(qos: .background)))
            .subscribe( Realm.rx.add(configuration: conf) )
            .addDisposableTo(bag)
        
        // subscribe on current/write on a realm in background
        Observable.from([[Message("7"), Message("8")]])
            .observeOn( ConcurrentDispatchQueueScheduler(
                queue: DispatchQueue.global(qos: .background)))
            .subscribe(onNext: {messages in
                let realm = try! Realm(configuration: conf)
                try! realm.write {
                    realm.add(messages)
                }
            })
            .addDisposableTo(bag)
        
        
        waitForExpectations(timeout: 5.0, handler: {error in
            XCTAssertNil(error)
            let finalResult = observer.events.last!.value.element!
            XCTAssertTrue(finalResult.count == 8, "The final amount of objects in realm are not correct")
            XCTAssertTrue((try! Realm(configuration: conf)).objects(Message.self).sorted(byKeyPath: "text")
                .reduce("", { acc, el in acc + el.text
            }) == "12345678" /*😈*/, "The final list of objects is not the one expected")
        })
    }
}
