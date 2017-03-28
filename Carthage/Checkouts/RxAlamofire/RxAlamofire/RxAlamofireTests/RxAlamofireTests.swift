//
//  RxAlamofireTests.swift
//  RxAlamofireTests
//
//  Created by Junior B. on 23/08/15.
//  Copyright © 2015 Bonto.ch. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxBlocking
import Alamofire
import OHHTTPStubs
import RxAlamofire

@testable import Alamofire

private struct Dummy {
	static let DataStringContent = "Hello World"
	static let DataStringData = DataStringContent.data(using: String.Encoding.utf8)!
	static let DataJSONContent = "{\"hello\":\"world\", \"foo\":\"bar\", \"zero\": 0}"
	static let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
	static let GithubURL = "http://github.com/RxSwiftCommunity"
}

class RxAlamofireSpec: XCTestCase {
	
	var manager: SessionManager!
	
	let testError = NSError(domain: "RxAlamofire Test Error", code: -1, userInfo: nil)
	let disposeBag = DisposeBag()
	
	//MARK: Configuration
	override func setUp() {
		super.setUp()
		manager = SessionManager()
		
		_ = stub(condition: isHost("mywebservice.com")) { _ in
			return OHHTTPStubsResponse(data: Dummy.DataStringData, statusCode:200, headers:nil)
		}
		
		_ = stub(condition: isHost("myjsondata.com")) { _ in
			return OHHTTPStubsResponse(data: Dummy.DataJSON, statusCode:200, headers:["Content-Type":"application/json"])
		}
	}
	
	override func tearDown() {
		super.tearDown()
		OHHTTPStubs.removeAllStubs()
	}
	
	//MARK: Tests
	func testBasicRequest() {
        do {
            let (result, string) = try requestString(HTTPMethod.get, "http://mywebservice.com").toBlocking().first()!
            XCTAssertEqual(result.statusCode, 200)
            XCTAssertEqual(string, Dummy.DataStringContent)
        } catch {
            XCTFail("\(error)")
        }
	}
	
	func testJSONRequest() {
        do {
            let (result, obj) = try requestJSON(HTTPMethod.get, "http://myjsondata.com").toBlocking().first()!
            let json = obj as! [String : Any]
            XCTAssertEqual(result.statusCode, 200)
            XCTAssertEqual(json["hello"] as! String, "world")
        } catch {
            XCTFail("\(error)")
        }
	}

    func testProgress() {
        do {
            let dataRequest = try request(HTTPMethod.get, "http://myjsondata.com").toBlocking().first()!
            let progressObservable = dataRequest.rx.progress().replayAll()
            let _ = progressObservable.connect()
            let delegate = dataRequest.delegate as! DataTaskDelegate
            let progressHandler = delegate.progressHandler!
            [(1000, 4000), (4000, 4000)].forEach { completed, total in
                let progress = Alamofire.Progress()
                progress.completedUnitCount = Int64(completed)
                progress.totalUnitCount = Int64(total)
                progressHandler.closure(progress)
            }
            let actualEvents = try progressObservable.toBlocking().toArray()
            let expectedEvents = [
                RxProgress(bytesWritten: 0, totalBytes: 0),
                RxProgress(bytesWritten: 1000, totalBytes: 4000),
                RxProgress(bytesWritten: 4000, totalBytes: 4000),
            ]
            XCTAssertEqual(actualEvents.count, expectedEvents.count)
            for i in 0..<actualEvents.count {
                XCTAssertEqual(actualEvents[i], expectedEvents[i])
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testRxProgress() {
        let subject = RxProgress(bytesWritten: 1000, totalBytes: 4000)
        XCTAssertEqual(subject.bytesRemaining, 3000)
        XCTAssertEqualWithAccuracy(subject.completed, 0.25, accuracy: 0.000000001)
        let similar = RxProgress(bytesWritten: 1000, totalBytes: 4000)
        XCTAssertEqual(subject, similar)
        let different = RxProgress(bytesWritten: 2000, totalBytes: 4000)
        XCTAssertNotEqual(subject, different)
    }
}
