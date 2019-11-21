//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 21/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    let store: FeedStore
    let currentDate: Date
    
    init(store: FeedStore, currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, with: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, currentDate: self.currentDate) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

protocol FeedStore {
    typealias CompletionWithError = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping CompletionWithError)
    func insert(_ items: [FeedItem], currentDate: Date, completion: @escaping CompletionWithError)
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulOldCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: timestamp)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items: items, timestamp: timestamp)])
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
        
        var recievedError: Error?
        sut?.save([uniqueItem()]) { recievedError = $0 }
        sut = nil
        store.completeDeletion(with: deletionError)
        
        XCTAssertNil(recievedError)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date())
        let insertionError = anyNSError()
        
        var recievedError: Error?
        sut?.save([uniqueItem()]) { recievedError = $0 }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: insertionError)
        
        XCTAssertNil(recievedError)
    }
    
    // MARK: - Helpers
    
    private class FeedStoreSpy: FeedStore {
        
        typealias CompletionWithError = (Error?) -> Void
        
        enum Message: Equatable {
            case deleteCachedFeed
            case insert(items: [FeedItem], timestamp: Date)
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
        
        func insert(_ items: [FeedItem], currentDate: Date, completion: @escaping CompletionWithError) {
            recievedMessages.append(.insert(items: items, timestamp: currentDate))
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
        var recievedError: Error?
        sut.save([uniqueItem()]) { error in
            recievedError = error
            exp.fulfill()
        }
        action()
        XCTAssertEqual(recievedError as NSError?, expectedError, file: file, line: line)
        wait(for: [exp], timeout: 1.0)
    }
    
    func uniqueItem() -> FeedItem {
        return FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: anyURL()
        )
    }
    
    func anyURL() -> URL {
        return URL(string: "http//aurl.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
