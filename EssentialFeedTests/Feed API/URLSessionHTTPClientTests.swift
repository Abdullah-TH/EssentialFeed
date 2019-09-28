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
    
    init(session: URLSession = .shared) {
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
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "http://aurl.com")!
        let error = NSError(domain: "any error", code: 1, userInfo: nil)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        
        let exp = expectation(description: "wait for completion")
        let client = URLSessionHTTPClient()
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
        URLProtocolStub.stopInterceptingRequets()
    }
    
    // MARK: Helpers
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequets() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        static func stub(url: URL, data: Data?, response: HTTPURLResponse?, error: Error?) {
            let stub = Stub(data: data, response: response, error: error)
            stubs[url] = stub
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
