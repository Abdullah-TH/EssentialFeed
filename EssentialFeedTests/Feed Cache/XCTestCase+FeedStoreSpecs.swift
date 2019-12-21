//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 21/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrival")
        
        sut.retrieveCachedFeed { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(expected.feed, retrieved.feed, file: file, line: line)
                XCTAssertEqual(expected.timestamp, retrieved.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to recieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    func insert(
        cache: (feed: [LocalFeedImage], timestamp: Date),
        to sut: FeedStore
    ) -> Error? {
        let exp = expectation(description: "wait for cache insertion")
        var recievedError: Error?
        sut.insert(feed: cache.feed, currentDate: cache.timestamp) { insertionError in
            recievedError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recievedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var recievedError: Error?
        sut.deleteCachedFeed { deletionError in
            recievedError = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recievedError
    }
    
}
