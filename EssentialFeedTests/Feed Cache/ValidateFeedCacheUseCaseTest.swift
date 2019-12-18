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
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        let feed = uniqueImageFeed()
        let lessThanSevenDaysTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        sut.validateCache()
        store.completeRetrieval(with: feed.localImageFeed, timestamp: lessThanSevenDaysTimeStamp)
        
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    func anyURL() -> URL {
        return URL(string: "http//aurl.com")!
    }
    
    func uniqueImage() -> FeedImage {
        return FeedImage(
            id: UUID(),
            description: nil,
            location: nil,
            url: anyURL()
        )
    }
    
    func uniqueImageFeed() -> (imageFeed: [FeedImage], localImageFeed: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let localFeed = feed.map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
        return (feed, localFeed)
    }

}

private extension Date {
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
