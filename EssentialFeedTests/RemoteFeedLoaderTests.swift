//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 07/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let url = URL(string: "https://a-url.com")!
        let (_, client) = makeSUT(url: url)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load() {_,_  in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load() {_,_  in }
        sut.load() {_,_  in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://a.url.com")!)
        var capturedErros = [RemoteFeedLoader.Error]()
        remoteFeedLoader.load() { error, _  in
            if let error = error {
                capturedErros.append(error)
            }
        }
        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErros, [.connectivityError])
    }
    
    func test_load_deliversErrorOnNon200() {
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://a.url.com")!)
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach() { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            remoteFeedLoader.load() { error,_  in
                if let error = error {
                    capturedErrors.append(error)
                }
            }
            client.complete(with: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(with statusCode: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
            messages[index].completion(nil, response)
        }
    }
    
    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}
