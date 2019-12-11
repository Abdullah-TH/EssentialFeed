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
}
