//
//  LoadFeedFronCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 12/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedFronCacheUseCaseTest: XCTestCase {
            
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_failedOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedFeedOnNonExpiredOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let nonExpiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge).adding(seconds: 1) // just one second before cache expired
        
        expect(sut, toCompleteWith: .success(feed.imageFeed), when: {
            store.completeRetrieval(with: feed.localImageFeed, timestamp: nonExpiredTimeStamp)
        })
    }
    
    func test_load_deliversNoImagesOnExactCacheExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let expiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge)
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.localImageFeed, timestamp: expiredTimeStamp)
        })
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let expiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge).adding(seconds: -1)
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.localImageFeed, timestamp: expiredTimeStamp)
        })
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let nonExpiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge).adding(seconds: 1)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.localImageFeed, timestamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExactCacheExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let expiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.localImageFeed, timestamp: expiredTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve,])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let expiredTimeStamp = fixedCurrentDate.adding(days: -cacheMaxAge).adding(seconds: -1)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.localImageFeed, timestamp: expiredTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesNotDelieverResultAfterSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date())
        
        var recievedResults = [LocalFeedLoader.LoadResult]()
        sut?.load() { recievedResults.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssert(recievedResults.isEmpty)
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
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
        when action: () -> (),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            case let (.failure(recievedError), .failure(expectedError)):
                XCTAssertEqual(recievedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected success, got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
