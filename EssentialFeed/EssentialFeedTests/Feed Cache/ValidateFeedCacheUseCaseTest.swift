//
//  ValidateFeedCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 18/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let nonExpiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge).adding(seconds: 1)
        
        sut.validateCache()
        store.completeRetrieval(with: feed.localImageFeed, timestamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCache_deleteOnExactCacheExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let expiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge)
        
        sut.validateCache()
        store.completeRetrieval(with: feed.localImageFeed, timestamp: expiredTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deleteExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let expiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge).adding(seconds: -1)
        
        sut.validateCache()
        store.completeRetrieval(with: feed.localImageFeed, timestamp: expiredTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date())
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: Date = Date(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(instance: store, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, store)
    }
}
