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
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader(client: client)
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestedDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader(client: client)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}
