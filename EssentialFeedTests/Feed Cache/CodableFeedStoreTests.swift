//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 21/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
    override func setUp() {
        super.setUp()
        removeArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        removeArtifacts()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieveTwice_deliversEmptyOnEmptyCacheWithNoSideEffects() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localImageFeed
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localImageFeed
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrive_deliversFailureOnRetrivalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrive_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let insertionError = insert(cache: (uniqueImageFeed().localImageFeed, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let feed = uniqueImageFeed()
        let timestamp = Date()
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        
        let latestFeed = uniqueImageFeed()
        let latestTimestamp = Date()
        insert(cache: (latestFeed.localImageFeed, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: latestFeed.localImageFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed.localImageFeed, timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
         let sut = makeSUT()
         let deletionError = deleteCache(from: sut)
         XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
     }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected successful deletion")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        deleteCache(from: sut)
                
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
    
    // MARK: - Helpers
    
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(instance: sut)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
         return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
     }
    
    private func removeArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
