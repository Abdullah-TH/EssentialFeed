//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Abdullah Althobetey on 19/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        let client = URLSessionHTTPClient()
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let loader = RemoteFeedLoader(client: client, url: url)
        
        var capturedResult: LoadFeedResult?
        let exp = expectation(description: "wait for completion")
        loader.load { result in
            capturedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        
        switch capturedResult {
        case let .success(items)?:
            XCTAssert(items.count == 8)
        case let .failure(error)?:
            XCTFail("Expected successfull feed result, got \(error) instead")
        default:
            XCTFail("Expected successfull feed result, got no result instead")
        }
    }
}
