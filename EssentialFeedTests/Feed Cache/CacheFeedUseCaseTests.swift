//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 21/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let feed = [uniqueImage(), uniqueImage()]
        
        sut.save(feed) { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed().feed
        let deletionError = anyNSError()
        
        sut.save(feed) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulOldCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: timestamp)
        let (feed, localFeed) = uniqueImageFeed()
        
        sut.save(feed) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(localFeed: localFeed, timestamp: timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        expect(sut, toCompleteWith: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        expect(sut, toCompleteWith: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date())
        let deletionError = anyNSError()
        
        var recievedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().feed) { recievedResults.append($0) }
        sut = nil
        store.completeDeletion(with: deletionError)
        
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date())
        let insertionError = anyNSError()
        
        var recievedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().feed) { recievedResults.append($0) }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: insertionError)
        
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private class FeedStoreSpy: FeedStore {
        
        typealias CompletionWithError = (Error?) -> Void
        
        enum Message: Equatable {
            case deleteCachedFeed
            case insert(localFeed: [LocalFeedImage], timestamp: Date)
        }
        
        private(set) var recievedMessages = [Message]()
        private var deletionCompletions = [CompletionWithError]()
        private var insertionCompletions = [CompletionWithError]()
        
        func deleteCachedFeed(completion: @escaping CompletionWithError) {
            recievedMessages.append(.deleteCachedFeed)
            deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error?, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ localFeed: [LocalFeedImage], currentDate: Date, completion: @escaping CompletionWithError) {
            recievedMessages.append(.insert(localFeed: localFeed, timestamp: currentDate))
            insertionCompletions.append(completion)
        }
        
        func completeInsertion(with error: Error?, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
    
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
    
    func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedError: NSError?,
        file: StaticString = #file,
        line: UInt = #line,
        when action: () -> ()
    ) {
        let exp = expectation(description: "Wait for save completion")
        var recievedResults = [LocalFeedLoader.SaveResult]()
        sut.save([uniqueImage()]) { error in
            recievedResults.append(error)
            exp.fulfill()
        }
        action()
        XCTAssertEqual(recievedResults.map { $0 as NSError? }, [expectedError], file: file, line: line)
        wait(for: [exp], timeout: 1.0)
    }
    
    func uniqueImage() -> FeedImage {
        return FeedImage(
            id: UUID(),
            description: nil,
            location: nil,
            url: anyURL()
        )
    }
    
    func uniqueImageFeed() -> (feed: [FeedImage], localFeed: [LocalFeedImage]) {
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
    
    func anyURL() -> URL {
        return URL(string: "http//aurl.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
