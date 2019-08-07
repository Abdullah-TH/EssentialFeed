//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 07/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.execute(url: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func execute(url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestedDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func execute(url: URL) {
            requestedURL = url
        }
    }
}
