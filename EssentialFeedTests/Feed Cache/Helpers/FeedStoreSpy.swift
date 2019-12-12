//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 12/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum Message: Equatable {
        case deleteCachedFeed
        case insert(localFeed: [LocalFeedImage], timestamp: Date)
        case retrieve
    }
    
    private(set) var recievedMessages = [Message]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        recievedMessages.append(.deleteCachedFeed)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error?, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ localFeed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        recievedMessages.append(.insert(localFeed: localFeed, timestamp: currentDate))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error?, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func load(completion: @escaping RetrievalCompletion) {
        recievedMessages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error?, at index: Int = 0) {
        retrievalCompletions[index](error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](nil)
    }
}
