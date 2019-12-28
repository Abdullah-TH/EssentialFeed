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
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore) {
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatRetrieveTwiceDeliversEmptyOnEmptyCachWithNoSideEffects(on sut: FeedStore) {
        expect(sut, toRetrieveTwice: .success(.empty))
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore) {
        let feed = uniqueImageFeed().localImageFeed
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore) {
        let feed = uniqueImageFeed().localImageFeed
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
        expect(sut, toRetrieveTwice: .success(.found(feed: feed, timestamp: timestamp)))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore) {
        let insertionError = insert(cache: (uniqueImageFeed().localImageFeed, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore) {
        let feed = uniqueImageFeed()
        let timestamp = Date()
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        
        let latestFeed = uniqueImageFeed()
        let latestTimestamp = Date()
        insert(cache: (latestFeed.localImageFeed, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: latestFeed.localImageFeed, timestamp: latestTimestamp)))
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func assertThatDeleteHasNoSideEffectOnEmptyCache(on sut: FeedStore) {
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore) {
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected successful deletion")
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore) {
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        deleteCache(from: sut)
                
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatStoreSideEffecsRunSerially(on sut: FeedStore) {
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let operation1 = expectation(description: "Wait for operation 1")
        sut.insert(feed: uniqueImageFeed().localImageFeed, currentDate: Date()) { _ in
            completedOperationsInOrder.append(operation1)
            operation1.fulfill()
        }
        
        let operation2 = expectation(description: "Wait for operation 1")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(operation2)
            operation2.fulfill()
        }
        
        let operation3 = expectation(description: "Wait for operation 1")
        sut.insert(feed: uniqueImageFeed().localImageFeed, currentDate: Date()) { _ in
            completedOperationsInOrder.append(operation3)
            operation3.fulfill()
        }
        
        wait(for: [operation1, operation2, operation3], timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [operation1, operation2, operation3], "Expected side-effects to run serially, but operations finished in the wrong order")
    }
    
}

// MAKR: - Helpers

extension FeedStoreSpecs where Self: XCTestCase {
    
    func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: FeedStore.RetrieveResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrival")
        
        sut.retrieveCachedFeed { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.empty), .success(.empty)), (.failure, .failure):
                break
            case let (.success(.found(expected)), .success(.found(retrieved))):
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
        toRetrieveTwice expectedResult: FeedStore.RetrieveResult,
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
