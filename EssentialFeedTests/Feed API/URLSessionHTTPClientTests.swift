//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 26/09/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://aurl.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let client = URLSessionHTTPClient(session: session)
        client.get(from: url) { _ in }
        
        XCTAssertTrue(task.resumeCallCount == 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://aurl.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "any error", code: 1, userInfo: nil)
        session.stub(url: url, error: error)
        
        let exp = expectation(description: "wait for completion")
        let client = URLSessionHTTPClient(session: session)
        client.get(from: url) { result in
            switch result {
            case let .failure(recievedError as NSError):
                XCTAssertTrue(recievedError == error)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    
    private class URLSessionSpy: URLSession {
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            let stub = Stub(task: task, error: error)
            stubs[url] = stub
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("No stub found for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stubs[url]?.task ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }

}
