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
    
    private struct UnexpectedValueRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequets()
    }
    
    func test_getFromURL_performsGetRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let recievedError = resultForError(data: nil, response: nil, error: requestError)
        XCTAssertTrue(recievedError as NSError? == requestError)
    }
    
    func test_getFromURL_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultForError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultForError(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultForError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultForError(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(recievedData, recievedResponse):
                XCTAssertEqual(recievedData, data)
                XCTAssertEqual(recievedResponse.url, response.url)
                XCTAssertEqual(recievedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_succeedWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        let exp = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(recievedData, recievedResponse):
                let emptyData = Data()
                XCTAssertEqual(recievedData, emptyData)
                XCTAssertEqual(recievedResponse.url, response.url)
                XCTAssertEqual(recievedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://aurl.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultForError(data: Data?, response: URLResponse?, error: Error?) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "wait for completion")
        
        var recievedError: Error?
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                recievedError = error
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return recievedError
    }
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequets() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
