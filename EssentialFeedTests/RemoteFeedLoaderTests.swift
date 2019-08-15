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
        sut.load() {_ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load() {_ in }
        sut.load() {_ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://a.url.com")!)
        var capturedErros = [RemoteFeedLoader.Error]()
        remoteFeedLoader.load() { error in
            capturedErros.append(error)
        }
        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErros, [.connectivityError])
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[0].completion(error)
        }
        
        func complete(with statusCode: Int) {
            
        }
    }
    
    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}
